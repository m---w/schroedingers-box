/*
Schroedinger's Box
Logic and DSP
SuperCollider Patch
2021 Jason Svoronos-Kanavas, Marian Weger
*/

/*===================== BELA SETUP =====================*/

s = Server.default;
~hostname = "hostname".unixCmdGetStdOut.replace("\n","").asSymbol; // get system hostname

// Set up options
if(~hostname==\bela, { // If running on Bela
	s.options.numAnalogInChannels = 4;
	s.options.numAnalogOutChannels = 4;
	s.options.numDigitalChannels = 0;
	s.options.maxLogins = 4;
	s.options.blockSize = 64;
	s.options.numInputBusChannels = 4;
	s.options.numOutputBusChannels = 8;
	n = [ NetAddr("192.168.0.101", 57120), NetAddr("192.168.0.102", 57120), NetAddr("192.168.0.103", 57120) ]; // set GUI addresses
	"Bela recognized itself as Bela.".postln;
}, { // If running elsewhere (debug)
	n = [ NetAddr("localhost", 57120) ];
	"No Bela detected. --> Debug mode.".postln;
});


/*===================== VARIABLE INITIALIZATIONS =====================*/

// Dictionaries
x = (); // synth dictionary
p = (); // parameter dictionary
p.tt = (); // test tone parameters
p.primary = (); // primary sound parameters
p.secondary = (); // secondary sound parameters
p.outcome = (); // outcome sound parameters
p.od = (); // onset detection parameters
p.master = (); // master parameters
q = (); // other parameters

// Onset Detection
~tbodTriggered = false; // flag to store if TBOD has triggered
~fbodAgrees = false; // flag to store if FBOD agreed with TBOD
~debugOnsets = true; // debug printing for onset detection
~debugSound = true; // debug printing for sound triggering

// Secondary sound
q[\secondaryMinDel] = 0.5;
q[\secondaryMaxDel] = 1.0;

// Primary sound
q[\combFiltMinFreq] = 20.0;
q[\combFiltMaxFreq] = 20000.0;

// Sound
~globalvel = 0.0; // init velocity
q[\playbackRand] = 0.1;


/*===================== GUI CONTROLS =====================*/


// receive OSC from GUI: define function for Onset Detection
~oscSetOD = {|addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			// ("OSC incoming:"+time+key+val).postln;
			("OSC incoming:"+addr+val).postln;
		});
		p.od[addr] = val;
		if(x[\od].isPlaying, {
			x[\od].set(addr, val);
		});
	}, addr);
};

// receive OSC from GUI: create receivers
~oscSetOD.(\tbThreshDB);
~oscSetOD.(\fbThreshDB);
~oscSetOD.(\fbRelaxtime);
~oscSetOD.(\fbFloorDB);
~oscSetOD.(\fbMingap);
~oscSetOD.(\fbMedianspan);
~oscSetOD.(\velDelay);
~oscSetOD.(\tbRefPeriod);
~oscSetOD.(\tbLpf1Freq);
~oscSetOD.(\tbLpf2Freq);
~oscSetOD.(\tbHpfFreq);
~oscSetOD.(\cancelDel);


// OSC receiver function for global parameters
~oscSetq = { |addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			("OSC incoming:"+addr+val).postln;
		});
		q[addr] = val;
	}, addr);
};

~oscSetq.(\playbackRand);
~oscSetq.(\combFiltMinFreq);
~oscSetq.(\combFiltMaxFreq);
~oscSetq.(\breakingThreshold);
~oscSetq.(\secondaryMinDel);
~oscSetq.(\secondaryMaxDel);

// OSC Receiver function for synth parameters
~oscSetp = { |dict, key, addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			("OSC incoming:"+addr+val).postln;
		});
		p[dict][key] = val; // update value in dictionary

		// update the corresponding synth
		switch(dict,
			\primary, {
				v.set([key, val], lat: nil);
			},
			\secondary, {
				if(x[\secondary].isPlaying, {
					x[\secondary].set(key, val);
				});
			},
			\outcome, {
				if(x[\outcome].isPlaying, {
					x[\outcome].set(key, val);
				});
			},
			\master, {
				if(x[\master].isPlaying, {
					x[\master].set(key, val);
				});
			}
		);


	}, addr);
};

// Primary Sound
~oscSetp.(\primary, \vel, \defaultVel);
~oscSetp.(\primary, \velUpdateLag, \velUpdateLag);
~oscSetp.(\primary, \combFiltDryWet, \combFiltDryWet);
~oscSetp.(\primary, \level, \primaryDB);

// Secondary Sound
~oscSetp.(\secondary, \upperCutoff, \secondaryCutoff);
~oscSetp.(\secondary, \level, \secondaryDB);

// Outcome Sound
~oscSetp.(\outcome, \level, \outcomeDB);

// Master
~oscSetp.(\master, \primaryLevel, \primaryMasterDB);
~oscSetp.(\master, \secondaryLevel, \secondaryMasterDB);
~oscSetp.(\master, \outcomeLevel, \outcomeMasterDB);
~oscSetp.(\master, \lpf, \masterLPF);
~oscSetp.(\master, \hpf, \masterHPF);

// Test Tone Generator
~oscSetpTT = {|key| ~oscSetp.(\tt, key, key)}; // shortcut function
~oscSetpTT.(\testFreq);
~oscSetpTT.(\noiseMasterDB);
~oscSetpTT.(\sineMasterDB);
~oscSetpTT.(\toggleSine);
~oscSetpTT.(\toggleNoise);
~oscSetpTT.(\toggle1);
~oscSetpTT.(\toggle2);
~oscSetpTT.(\toggle3);
~oscSetpTT.(\toggle4);
~oscSetpTT.(\flip1);
~oscSetpTT.(\flip2);
~oscSetpTT.(\flip3);
~oscSetpTT.(\flip4);

~oscSetT = { |addr, func, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			("OSC incoming:"+addr+val).postln;
		});
		p.tt[addr] = val;
		func.(val);
	}, addr);
};

~oscSetT.(\toggleMaster, {|val|
	if(val==1, {
		if(x[\tt].isPlaying.not, {
			x[\tt] = Synth.new(\tt, p.tt.asKeyValuePairs, addAction: \addToHead).register;
		});
	}, {
		if(x[\tt].isPlaying, {
			x[\tt].free;
		});
	});
});



/*===================== SOUND SELECTION =====================*/


OSCdef(\preset, { | msg, time |
	~preset = msg[1].asInteger; // set preset
	("New sound selected:"+~preset).postln; // notify

	// load default settings (these may be defined in the preset)
	~addsound = false; // secondary sound on/off
	~outcome = false; // outcome sound on/off
	~voices = 5; // number of simultaneous voices (polyphony)
	~ampfactor = 0.0; // primary sound level
	~ampfactorcat = inf.neg; // secondary sound level
	~ampfactoroutcome = inf.neg; // outcome sound level
	~outcomePossible = true; // outcome didn't happen yet?
	~breakingThreshold = 0.1; // threshold for breaking glass
	~secondaryCutoff = 1000.0; // cutoff for secondary sound
	~onsetCounter = 0; // onset counter (for triggering secondary sound)
	~sound.do{|item| item.free}; // free buffers of primary sounds
	~soundcat_sum.do{|item| item.free}; // free buffers of secondary sounds
	~combFilterDryWet = 1.0.neg; // dry/wet for comb filter

	// Load preset
	if(~preset > 0){
		("./presets/sound"++~preset.asInteger ++".scd").standardizePath.load; // load preset file
	}{
		// Notify if no preset was selected
		"No preset selected. Press the button to start!".postln;
	};

	// init primary sound
	p.primary[\level] = ~ampfactor;
	p.primary[\combFilterDryWet] = ~combFilterDryWet;
	~soundSize = ~sound.size; // number of primary sounds in this preset
	~soundIndArray = (0..(~soundSize-1)); // array of primary sound indices
	~lastSoundID = ~soundIndArray.choose; // choose a random start index
	v.free; // free previous voicer instance
	v = Voicer.new(voices: ~voices, things: \primary, bus: p.primary[\busnum], addAction: \addToHead); // start new voicer
	v.latency = nil; // set latency of the voicer. nil means as soon as possible.
	v.stealer = \preferLate; // set voice stealing algorithm

	// init secondary sound
	p.secondary[\level] = ~ampfactorcat;
	p.secondary[\upperCutoff] = ~secondaryCutoff;
	if(~addsound, {
		~addSoundSize = ~soundcat_sum.size; // number of secondary sounds in this preset
		~addSoundIndArray = (0..(~addSoundSize-1)); // array of secondary sound indices
		~lastAddSoundID = ~addSoundIndArray.choose; // choose a random start index
	});

	// init outcome sound
	if(~outcome, {
		p.outcome[\level] = ~ampfactoroutcome;
	});

	// update remote GUI
	n.do{|item| item.sendMsg(\bela, \primaryDB, p.primary[\level]) };
	n.do{|item| item.sendMsg(\bela, \secondaryDB, p.secondary[\level]) };
	n.do{|item| item.sendMsg(\bela, \outcomeDB, p.outcome[\level]) };
	n.do{|item| item.sendMsg(\bela, \secondaryCutoff, p.secondary[\upperCutoff]) };
	n.do{|item| item.sendMsg(\bela, \combFilterDryWet, p.primary[\combFilterDryWet]) };

	//finish
	if(~preset>=666){s.freeAll};

},'/preset');


/*===================== RANDOMIZATION =====================*/


~chooseSound = {
	// set new sample ID (random from array, but not same as previous)
	~lastSoundID = ~soundIndArray[~soundIndArray.rejectIndices({|i| i==~lastSoundID})].choose;
};

~chooseAddSound = {
	// set new sample ID (random from array, but not same as previous)
	~lastAddSoundID = ~addSoundIndArray[~addSoundIndArray.rejectIndices({|i| i==~lastAddSoundID})].choose;
};

~randRate = {
	1.0+q[\playbackRand].bilinrand; // +-random percent playback rate
};

~randCombFreq = {
	rrand(q[\combFiltMinFreq], q[\combFiltMaxFreq]);
};

~randAddDelay = {
	rrand(q[\secondaryMinDel], q[\secondaryMaxDel]);
};


/*===================== NEW VOICE TRIGGER =====================*/


// Secondary sound
~maybeNewSecondarySound = {
	if(x[\secondary].isPlaying.not && ~addsound){
		~onsetCounter = ~onsetCounter + 1; // increment onset counter

		// Random decision (tune inMin and inMax to set minimum and maximum number of hits for 0% and 100% chance, respectively)
		if( ~onsetCounter.linlin(inMin: 1, inMax: 7, outMin: 0.0, outMax: 1.0, clip: 'minmax').coin ) {
			// Trigger new secondary sound
			p.secondary[\bufnum] = ~soundcat_sum[~chooseAddSound.()].bufnum;
			p.secondary[\rate] = ~randRate.();
			p.secondary[\deltime] = ~randAddDelay.();
			x[\secondary] = Synth.new(\secondary, p.secondary.asKeyValuePairs, addAction: \addToHead).register;
			if(~debugSound, {
				"Secondary sound started.".postln;
			});
			~onsetCounter = 1; // reset onset counter to 1 (so that there is already some small chance to directly trigger secondary sound again next time
		};

	};
};

// Primary sound
~newPrimarySound = {
	// set parameters
	p.primary[\bufnum] = ~sound[~chooseSound.()].bufnum;
	p.primary[\rate] = ~randRate.();
	p.primary[\combFiltFreq] = ~randCombFreq.();
	// play voice
	v.trigger(freq: 1, gate: 1, args: p.primary.asKeyValuePairs, lat: nil);
};


/*===================== TRIGGERING =====================*/

// ONSET DETECTION
~oscReceiverOD = OSCFunc({ |msg, time|
	var id = msg[2];
	var val = msg[3];

	// trigger only if preset other than 0!
	if(~preset>0, {

		// Triggering, Cancelling, and Velocity update LOGIC
		switch (id,
			0, { // False Alarm Cancellation
				if(~tbodTriggered&&~fbodAgrees.not, {
					~lastvoice.set([\gate, 0]);
					if(~debugOnsets, {
						("No confirmation from FBOD. --> Onset cancelled.").postln;
					});
				});
				~tbodTriggered = false;
				~fbodAgrees = false;
			},
			1, { // TBOD trigger new
				~lastvoice = ~newPrimarySound.(); // trigger new primary sound
				~maybeNewSecondarySound.(); // maybe trigger new secondary sound
				if(~debugOnsets, {
					("TBOD triggers new onset.").postln;
				});
				~tbodTriggered = true;
				~fbodAgrees = false;
			},
			2, { // FBOD trigger
				if( ~tbodTriggered, { // agree
					~fbodAgrees = true;
					if(~debugOnsets, {
						("FBOD agrees with TBOD.").postln;
					});
				}, { // trigger new
					~lastvoice = ~newPrimarySound.(); // trigger new primary sound
					~maybeNewSecondarySound.(); // maybe trigger new secondary sound
					if(~debugOnsets, {
						("FBOD triggers new onset.").postln;
					});
				});
			},
			3, { // Velocity update
				~globalvel = val;
				~lastvoice.set([\vel, ~globalvel.linexp(0.005, 0.35, 0.005, 0.7, \minmax)]);
				if(~debugOnsets, {
					("Velocity update:"+val).postln;
				});
			};
		);

		// Break glass
		if(~outcome&&~outcomePossible){
			if(~globalvel>~breakingThreshold){
				// 1. Release all primary sounds
				v.set([\gate, 0], lat: nil);
				// 2. Trigger new breaking sound
				p.outcome[\vel] = ~globalvel; // set velocity to global velocity
				p.outcome[\bufnum] = ~soundcat_sum[~chooseAddSound.()].bufnum; // choose random sample
				p.outcome[\rate] = ~randRate.(); // choose random playback rate
				x[\outcome] = Synth.new(\outcome, p.outcome.asKeyValuePairs, addAction: \addToHead); // create synth
				~outcomePossible = false; // outcome not possible anymore
			};
		};

	});

},'/tr', s.addr);



/*===================== WAIT FOR SERVER =====================*/

s.waitForBoot{


	/*===================== BUS ALLOCATION =====================*/

	// allocate busses
	p.primary[\busnum] = Bus.audio(s, numChannels: 1).postln;
	p.secondary[\busnum] = Bus.audio(s, numChannels: 1).postln;
	p.outcome[\busnum] = Bus.audio(s, numChannels: 1).postln;

	// map also to master busses
	p.master[\primaryBus] = p.primary[\busnum];
	p.master[\secondaryBus] = p.secondary[\busnum];
	p.master[\outcomeBus] = p.outcome[\busnum];


	/*===================== SYNTHDEFS =====================*/

	// PRIMARY SOUND
	SynthDef(\primary,{

		arg
		outbus = 0,
		gate = 1.0,
		vel = 0.0,
		bufnum = 0,
		level = inf.neg,
		rate = 1.0,
		combFiltDryWet = -1.0,
		combFiltFreq = 1000.0,
		velUpdateLag = 0.001;

		var sig, comb;

		sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: rate, trigger: gate, doneAction: 2); // play sample
		comb = sig - DelayN.ar(sig, maxdelaytime: 0.1, delaytime: combFiltFreq.reciprocal); // comb filter
		sig = XFade2.ar(sig, comb, combFiltDryWet); // crossfade between dry and comb-filtered
		sig = sig * EnvGen.ar(Env.asr(0.0, 1.0, 0.005), gate: gate, doneAction:2); // apply release envelope
		sig = vel.lag(velUpdateLag) * sig * level.dbamp; // apply velocity and master level
		Out.ar(outbus, sig); // play to bus

	}).add;

	SynthDef(\outcome,{

		arg
		outbus = 0,
		gate = 1.0,
		vel = 0.0,
		bufnum = 0,
		level = inf.neg,
		rate = 1.0;

		var sig, comb;

		sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: rate, trigger: gate, doneAction: 2); // play sample
		sig = vel * sig * level.dbamp; // apply velocity and master level
		Out.ar(outbus, sig); // play to bus

	}).add;


	// SECONDARY SOUND
	SynthDef(\secondary, {

		arg
		outbus = 0,
		bufnum = 0,
		level = inf.neg,
		deltime = 0.5,
		rate = 1.0,
		upperCutoff = 500;

		var sig, trigger;

		trigger = DelayN.ar(Trig.ar(1.0), deltime, deltime); // trigger after specified time
		sig = PlayBuf.ar(1, bufnum, rate, trigger, doneAction: 2); // play sample
		sig = LPF.ar(sig, upperCutoff); // low-pass filter to simulate damping through box
		sig = sig * level.dbamp; // apply amplitude
		Out.ar(outbus, sig);

	}).add;


	// MASTER BUS
	SynthDef(\master, {

		arg
		primaryBus = 0,
		secondaryBus = 0,
		outcomeBus = 0,
		primaryLevel = 0.0,
		secondaryLevel = 0.0,
		outcomeLevel = 0.0,
		lpf = 20000.0,
		hpf = 80.0;

		var primary, secondary, outcome, master;

		primary = In.ar(primaryBus, numChannels: 1) * primaryLevel.dbamp; // read primary bus and apply level
		secondary = In.ar(secondaryBus, numChannels: 1) * secondaryLevel.dbamp; // read secondary bus and apply level
		outcome = In.ar(outcomeBus, numChannels: 1) * outcomeLevel.dbamp; // read outcome bus and apply level

		master = primary + secondary + outcome; // just sum all sounds together

		// TODO: equalization!

		master = LPF.ar(HPF.ar(master, hpf), lpf).tanh; // output filtering and protection
		Out.ar(0, master!4); // write same signal to all output channels

	}).add;


	// ONSET DETECTION
	SynthDef(\od, {
		arg
		tbThreshDB = 0.0,
		fbThreshDB = 0.0,
		fbRelaxtime = 1.0,
		fbFloorDB = -20.0,
		fbMingap = 22,
		fbMedianspan = 22,
		velDelay = 0.006,
		tbRefPeriod = 0.03,
		tbLpf1Freq = 25.0,
		tbLpf2Freq = 25.0,
		tbHpfFreq = 4000.0,
		cancelDel = 1.0;

		var sigRaw, sig, sighpf, sigsquared, lpf1, derivative, lpf2, tsub, tbTrig, chain, fbTrigKR, fbTrigAR, vel;
		var sampleDur = 1.1/SampleRate.ir; // duration of one audio sample, plus 10 percent safety
		var nfft = 256; // FFT size in samples
		var frameDur = (nfft/SampleRate.ir)*1.1; // duration of one fft frame in seconds, plus safety of 10 percent. 5.4ms at 48kHz and 256samp fft size.
		var minusTwoPiT = 2.0.neg*pi/SampleRate.ir; // pre-computation
		var lpf1CoeffA = exp(tbLpf1Freq*minusTwoPiT); // feedback coefficient for 1st order lowpass filter (leaky integrator) (lpf1)
		var lpf2CoeffA = exp(tbLpf2Freq*minusTwoPiT); // feedback coefficient for 1st order lowpass filter (leaky integrator) (lpf2)
		var lpf1CoeffAm = 1.0-lpf1CoeffA; // pre-computation
		var lpf2CoeffAm = 1.0-lpf2CoeffA; // pre-computation

		sigRaw = SoundIn.ar([0,1,2,3]); // 4 input channels
		sig = sigRaw.sum; // downmix to mono

		//=== TBOD ===
		sighpf = HPF.ar(LPF.ar(sig, 16000.0), tbHpfFreq); // Highpass Filter. Turchet2018: 4000 for conga, 7500 for bongo/djembe/cajon
		sigsquared = sighpf.squared; // Squaring (get signal energy)
		lpf1 = Integrator.ar(lpf1CoeffAm*sigsquared, lpf1CoeffA); // Smoothing 1. Turchet2018: 25
		derivative = Slope.ar(lpf1); // 1st derivative = slope
		lpf2 = Integrator.ar(lpf2CoeffAm*derivative, lpf2CoeffA); // Smoothing 2. Turchet2018: 25
		// tsub = (0.01 * lpf1 - lpf2).max(0); // trend subtraction (inspired from Coyote)
		tsub = lpf2 - Median.ar(64, lpf2); // trend subtraction (inspired from Turchet2018: length 65 samples)
		// ttrig = Schmidt.ar(tsub, tbThreshDB.dbamp, tbThreshLowDB.dbamp); // thresholding with high and low threshold
		tbTrig = Trig.ar((tsub-tbThreshDB.dbamp).sign.max(0), tbRefPeriod); // simple thresholding, including a refractory period to prevent re-triggering within the given time
		SendTrig.ar(tbTrig, 1); // send TBOD trigger to language. ID 1 means TBOD.

		//=== FBOD ===
		chain = FFT(LocalBuf(nfft), sig, hop: 0.25, wintype: 1); // Turchet2018: winsize 256, hopsize 64. Wintype 1 is Hann window.
		fbTrigKR = Onsets.kr(chain, threshold: fbThreshDB.dbamp, odftype: \rcomplex, relaxtime: fbRelaxtime, floor: fbFloorDB.dbamp, mingap: fbMingap, medianspan: fbMedianspan); // rcomplex is best. if it takes up too much cpu, then use power.
		fbTrigAR = T2A.ar(fbTrigKR, offset: 0);
		SendTrig.ar(fbTrigAR, 2); // send FBOD trigger to language. ID 2 means FBOD.

		//=== FAC: false alarm cancellation ===
		SendTrig.ar(DelayN.ar(tbTrig, 0.1, cancelDel*frameDur), 0); // send FBOD cancel trigger to language. ID 0 means FBOD cancel (TBOD false alarm, FBOD correct rejection)

		//=== VD: velocity detection ===
		vel = RunningMax.ar(sig.abs, DelayN.ar(fbTrigAR, 0.1, velDelay+sampleDur)); // running max of input. reset delayed after FBOD trigger + 1 sample safety.
		SendTrig.ar(DelayN.ar(fbTrigAR, 0.1, velDelay), 3, value: vel); // send velocity value to language. Waiting time is set via velDelay.

	}).add;


	// TEST TONE GENERATOR
	SynthDef(\tt, {
		arg
		noiseMasterDB = -80.0,
		sineMasterDB = -80.0,
		testFreq = 400.0,
		toggleSine = 0.0,
		toggleNoise = 0.0,
		toggleMaster = 1.0,
		toggle1 = 0.0,
		toggle2 = 0.0,
		toggle3 = 0.0,
		toggle4 = 0.0,
		flip1 = 0.0,
		flip2 = 0.0,
		flip3 = 0.0,
		flip4 = 0.0;

		var noise = WhiteNoise.ar(noiseMasterDB.dbamp*toggleNoise); // white noise generator
		var sine = SinOsc.ar(testFreq, mul: sineMasterDB.dbamp*toggleSine); // sine tone generator
		var sig = (sine + noise) * toggleMaster; // monophonic test signal
		var flipToggles = [flip1, flip2, flip3, flip4].madd(2.0.neg,1.0); // flip phase switches
		var toggles = [toggle1, toggle2, toggle3, toggle4]; // channel state switches
		var sigArray = toggles*flipToggles*sig; // 4ch test signal
		Out.ar(0, (sigArray!2).flat); // play same signal to 1-4 and 5-8
	}).add;



	/*===================== MAIN =====================*/


	1.wait; // wait a second

	// start those synths that should always be running
	x[\od] = Synth.new(\od, p.od.asKeyValuePairs, addAction: \addToHead).register; // start onset detection synth
	x[\master] = Synth.new(\master, p.master.asKeyValuePairs, addAction: \addToTail).register; // start master synth


	// request parameters from GUI
	n.do{|item| item.sendMsg(\bela, \booted) }; // send request via OSC to all addresses


	"Main Patch READY.".postln;
};



/*===================== QUIT =====================*/

if(~hostname==\bela, { // If running on Bela
	ServerQuit.add({ 0.exit }); // quit if the button is pressed
});