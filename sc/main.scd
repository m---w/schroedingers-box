/*
Schroedinger's Box
SuperCollider Patch for Bela
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

x = (); // synth dictionary
p = (); // parameter dictionary
p[\testTone] = (); // test tone parameters
p[\sound] = (); // sound parameters
p[\onsetDetection] = (); // onset detection parameters




~tbodTriggered = false; // flag to store if TBOD has triggered
~fbodAgrees = false; // flag to store if FBOD agreed with TBOD
~glassflag = true; //glass already broke or cannot break
~globalvel = 0.0; // init velocity
~preset = 0; // init preset
~voices = 5; // init number of voices
~addsound = false; // secondary sound on/off
~outcome = false; // breaking sound on/off
~ampfactor = 0.0; // primary sound level
~ampfactorcat = inf.neg; // secondary sound level
~ampfactorGlobal = 0.0; // master volume initial value (can be set from GUI) GLOBAL
~ampfactorcatGlobal = 0.0; // cat volume initial value (can be set from GUI) GLOBAL
~onset_sum = 0;
~debugOnsets = true; // debug printing for onset detection
~defaultVel = 0.01; // default velocity when new voice is triggered
~breakingThreshold = 0.1; // threshold for breaking glass
~velUpdateLag = 0.001;
~combFiltMinFreq = 20.0;
~combFiltMaxFreq = 20000.0;
~combFiltDryWet = 0.0;
~addCutoff = 500.0;
~addMinDel = 0.5;
~addMaxDel = 1.0;
~playbackRand = 0.1;


/*===================== GUI CONTROLS =====================*/


// receive OSC from GUI: define function for Onset Detection
~oscSetOD = {|addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			// ("OSC incoming:"+time+key+val).postln;
			("OSC incoming:"+addr+val).postln;
		});
		p[\onsetDetection][addr] = val;
		if(x[\onsetDetection].isPlaying, {
			x[\onsetDetection].set(addr, val);
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


// receive OSC from GUI: define function for Test Tone Generator
~oscSetTT = {|addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			// ("OSC incoming:"+time+key+val).postln;
			("OSC incoming:"+addr+val).postln;
		});
		p[\testTone][addr] = val;
		if(x[\testTone].isPlaying, {
			x[\testTone].set(addr, val.asFloat);
		});
	}, addr);
};

// define OSC receivers for Test Tone Generator
~oscSetTT.(\testFreq);
~oscSetTT.(\noiseMasterDB);
~oscSetTT.(\sineMasterDB);
~oscSetTT.(\toggleSine);
~oscSetTT.(\toggleNoise);
~oscSetTT.(\toggle1);
~oscSetTT.(\toggle2);
~oscSetTT.(\toggle3);
~oscSetTT.(\toggle4);
~oscSetTT.(\flip1);
~oscSetTT.(\flip2);
~oscSetTT.(\flip3);
~oscSetTT.(\flip4);


// receive OSC from GUI: define function
~oscSetFunc = { |dict, addr, func, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			// ("OSC incoming:"+time+key+val).postln;
			("OSC incoming:"+addr+val).postln;
		});
		p[dict][addr] = val;
		func.(val);
	}, addr);
};

// receive OSC from GUI: create receivers
~oscSetFunc.(\sound, \mainDB, {|val| ~ampfactor=val.dbamp});
~oscSetFunc.(\sound, \catDB, {|val| ~ampfactorcat=val.dbamp});
~oscSetFunc.(\sound, \mainGlobalDB, {|val| ~ampfactorGlobal=val.dbamp});
~oscSetFunc.(\sound, \catGlobalDB, {|val| ~ampfactorcatGlobal=val.dbamp});
~oscSetFunc.(\sound, \playbackRand, {|val| ~playbackRand=val});
~oscSetFunc.(\sound, \defaultVel, {|val| ~defaultVel=val});
~oscSetFunc.(\sound, \velUpdateLag, {|val| ~velUpdateLag=val});
~oscSetFunc.(\sound, \combFiltMinFreq, {|val| ~combFiltMinFreq=val});
~oscSetFunc.(\sound, \combFiltMaxFreq, {|val| ~combFiltMaxFreq=val});
~oscSetFunc.(\sound, \combFiltDryWet, {|val| ~combFiltDryWet=val});
~oscSetFunc.(\sound, \breakingThreshold, {|val| ~breakingThreshold=val});
~oscSetFunc.(\sound, \addMinDel, {|val| ~addMinDel=val});
~oscSetFunc.(\sound, \addMaxDel, {|val| ~addMaxDel=val});
~oscSetFunc.(\sound, \addCutoff, {|val| ~addCutoff=val});



~oscSetFunc.(\testTone, \toggleMaster, {|val|
	if(val==1, {
		if(x[\testTone].isPlaying.not, {
			x[\testTone] = Synth.new(\testTone, p[\testTone].asKeyValuePairs).register;
		});
	}, {
		if(x[\testTone].isPlaying, {
			x[\testTone].free;
		});
	});
});


/*===================== SOUND SELECTION =====================*/


OSCdef(\preset, { | msg, time |
	~preset = msg[1].asInteger;
	("New sound selected:"+~preset).postln;

	// load default settings
	~addsound = false;
	~outcome = false;
	~voices = 5;
	~ampfactor = 0.0;
	~ampfactorcat = inf.neg;
	~glassflag = true; // glass already broke or cannot break
	~breakingThreshold = 0.1; // threshold for breaking glass


	if(~preset==0){
		"press the button to start".postln;
		n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB to GUI
		n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB to GUI
	};

	// load preset
	if(~preset > 0){
		var path = ("./loader/sound"++~preset.asInteger ++"/sound"++~preset.asInteger ++".scd").standardizePath; // path to preset file
		~sound.do{|item| item.free}; // free buffers of primary sounds
		~soundcat_sum.do{|item| item.free}; // free buffers of secondary sounds
		path.load; // load preset file
	};

	// init primary sound selection
	~soundSize = ~sound.size; // number of primary sounds in this preset
	~soundIndArray = (0..(~soundSize-1)); // array of primary sound indices
	~lastSoundID = ~soundIndArray.choose; // choose a random start index
	v.free; // free previous voicer instance
	v = Voicer.new(~voices, \sample_player); // start new voicer

	// voicer settings
	v.latency = nil; // set latency of the voicer. nil means as soon as possible.
	v.stealer = \preferLate; // set voice stealing algorithm


	// init secondary sound selection
	if(~addsound, {
		~addSoundSize = ~soundcat_sum.size; // number of secondary sounds in this preset
		~addSoundIndArray = (0..(~addSoundSize-1)); // array of secondary sound indices
		~lastAddSoundID = ~addSoundIndArray.choose; // choose a random start index
	});

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
	1.0+~playbackRand.bilinrand; // +-random percent playback rate
};

~randCombFreq = {
	rrand(~combFiltMinFreq, ~combFiltMaxFreq);
};

~randAddDelay = {
	rrand(~addMinDel, ~addMaxDel);
};


/*===================== NEW VOICE TRIGGER =====================*/


// function to trigger new voice
~voicetrigger = {
	var lastvoice; // variable to store voice that is returned by this function

	// Primary sound
	lastvoice = v.trigger(freq: 1, gate: 1, args: [\amp, ~defaultVel, \gate, 1, \bufnum, ~sound[~chooseSound.()].bufnum, \ampfactor, ~ampfactor*~ampfactorGlobal, \rate, ~randRate.(), \combFiltFreq, ~randCombFreq.(), \combFiltDryWet, ~combFiltDryWet, \velUpdateLag, ~velUpdateLag], lat: nil);

	// Secondary sound
	if(x[\addSound].isPlaying.not && ~addsound){
		~onset_sum = ~onset_sum + 1; // increment onset counter

		// Random decision (tune inMin and inMax to set minimum and maximum number of hits for 0% and 100% chance, respectively)
		if( ~onset_sum.linlin(inMin: 1, inMax: 7, outMin: 0.0, outMax: 1.0, clip: 'minmax').coin ) {
			// Trigger new secondary sound
			x[\addSound] = Synth.new(\addsound, [\bufnum, ~soundcat_sum[~chooseAddSound.()].bufnum, \amp, ~ampfactorcat*~ampfactorcatGlobal, \rate, ~randRate.(), \deltime, ~randAddDelay.(), \cutoff, ~addCutoff]).register;
			if(~debugSound, {
				"Secondary sound started.".postln;
			});
			~onset_sum = 1; // reset onset counter to 1 (so that there is already some small chance to directly trigger secondary sound again next time
		};
	};

	// Teturn this when evaluating the function:
	lastvoice;
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
				~lastvoice = ~voicetrigger.();
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
					~lastvoice = ~voicetrigger.();
					if(~debugOnsets, {
						("FBOD triggers new onset.").postln;
					});
				});
			},
			3, { // Velocity update
				~globalvel = val;
				~lastvoice.set([\amp, val.linexp(0.005, 0.35, 0.005, 0.7, \minmax)]);
				if(~debugOnsets, {
					("Velocity update:"+val).postln;
				});
			};
		);

		// Break glass
		if(~outcome&&~glassflag){
			if(~globalvel>~breakingThreshold){
				x[\breakingSound] = Synth.new(\sample_player, [\amp, val, \gate, 1, \bufnum, ~soundcat_sum[~chooseAddSound.()].bufnum, \ampfactor, ~ampfactor*~ampfactorGlobal, \rate, ~randRate.()]);
				~glassflag = false;
			};
		};

	});

},'/tr', s.addr);



/*===================== WAIT FOR SERVER =====================*/

s.waitForBoot{

	/*===================== SYNTHDEFS =====================*/

	// VOICE ALLOCATION
	v = Voicer.new(~voices, \sample_player);


	// PRIMARY SOUND
	SynthDef(\sample_player,{

		arg
		gate = 1.0,
		amp = 0.1,
		bufnum = 0,
		ampfactor = 1.0 ,
		rate = 1.0,
		combFiltDryWet = -1.0,
		combFiltFreq = 1000.0,
		velUpdateLag = 0.001;

		var sig, comb;

		sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: rate, trigger: gate, doneAction: 2); // play sample
		comb = sig - DelayN.ar(sig, maxdelaytime: 0.1, delaytime: combFiltFreq.reciprocal); // comb filter
		sig = XFade2.ar(sig, comb, combFiltDryWet); // crossfade between dry and comb-filtered
		sig = sig * EnvGen.ar(Env.asr(0.0, 1.0, 0.005), gate: gate, doneAction:2); // apply release envelope
		sig = amp.lag(velUpdateLag) * sig * ampfactor; // apply velocity and master level
		sig = LPF.ar(HPF.ar(sig, 80.0), 20000.0).tanh; // output filtering and protection
		Out.ar(0, sig!8); // play same signal to all outputs

	}).add;


	// SECONDARY SOUND
	SynthDef(\addsound, {

		arg
		bufnum = 0,
		amp = 0.5,
		deltime = 0.5,
		rate = 1.0,
		cutoff = 500;

		var sig, trigger;

		trigger = DelayN.ar(Trig.ar(1.0), deltime, deltime); // trigger after specified time
		sig = PlayBuf.ar(1, bufnum, rate, trigger, doneAction: 2); // play sample
		sig = LPF.ar(sig, cutoff); // low-pass filter to simulate damping through box
		sig = sig * amp; // apply amplitude
		sig = LPF.ar(HPF.ar(sig, 80.0), 20000.0).tanh; // output filtering and protection
		Out.ar(0, sig!8);

	}).add;


	// ONSET DETECTION
	SynthDef(\onsetDetection, {
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
		fbTrigKR = Onsets.kr(chain, fbThreshDB.dbamp, \rcomplex, relaxtime: fbRelaxtime, floor: fbFloorDB.dbamp, mingap: fbMingap, medianspan: fbMedianspan); // rcomplex is best. if it takes up too much cpu, then use power.
		fbTrigAR = T2A.ar(fbTrigKR, offset: 0);
		SendTrig.ar(fbTrigAR, 2); // send FBOD trigger to language. ID 2 means FBOD.

		//=== FAC: false alarm cancellation ===
		SendTrig.ar(DelayN.ar(tbTrig, 0.1, cancelDel*frameDur), 0); // send FBOD cancel trigger to language. ID 0 means FBOD cancel (TBOD false alarm, FBOD correct rejection)

		//=== VD: velocity detection ===
		vel = RunningMax.ar(sig.abs, DelayN.ar(fbTrigAR, 0.1, velDelay+sampleDur)); // running max of input. reset delayed after FBOD trigger + 1 sample safety.
		SendTrig.ar(DelayN.ar(fbTrigAR, 0.1, velDelay), 3, value: vel); // send velocity value to language. Waiting time is set via velDelay.

	}).add;


	// TEST TONE GENERATOR
	SynthDef(\testTone, {
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
	x[\onsetDetection] = Synth.new(\onsetDetection).register; // start onset detection synth

	// request parameters from GUI
	n.do{|item| item.sendMsg(\bela, \booted) }; // send request via OSC to all addresses

};



/*===================== QUIT =====================*/

if(~hostname==\bela, { // If running on Bela
	ServerQuit.add({ 0.exit }); // quit if the button is pressed
});