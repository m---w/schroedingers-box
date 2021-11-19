/*
Schroedinger's Box
SuperCollider Patch for Bela
2021 Jason Svoronos-Kanavas, Marian Weger
*/


s = Server.default;

// Set up options for the Bela
s.options.numAnalogInChannels = 4;
s.options.numAnalogOutChannels = 4;
s.options.numDigitalChannels = 0;
s.options.maxLogins = 4;
s.options.blockSize = 64;
s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 8;


s.waitForBoot{

	~button = 0;

	OSCdef(\next_sound, { | msg, time |
		var num = msg[2];


		//direct sample choosing via numberbox
		if(msg[1] == 'sam_num'){
			~button = num;
			("New sound selected:"+num).postln;
		};

		//button counter
		if(msg[1] == 1.0){
			~button = ~button + 1;
		};

		if(~button == 0){"press the button to start".postln;
		};

		if(~button > 0){var path = "./loader/sound"++~button.asInt ++"/sound"++~button.asInt ++".scd"; path.load;
		};

		//finish
		if(~button == 20){s.freeAll;
		};

	},'/soundpick/2');


	f = { | in = 0 |
		var temp, arr, val, suf;
		arr = in;
		suf = Pn(Pshuf(in, 1), inf).asStream;
		temp = suf.next;
		if(temp == ~last){
			arr = in;
			val = arr.remove(temp);
			// arr.postln;
			temp = arr.choose;
			arr = arr.add(val);
		};
		~last = temp;
		temp;
	};

	SynthDef(\sample_player,{
		| gate = 1, amp = 0.1, bufnum = 0, ampfactor = 1 |
		var sig, env, out;
		sig = PlayBuf.ar(numChannels:1, bufnum:bufnum, rate: Rand(0.9, 1.1), trigger: gate);
		p=1.0.linrand;
		sig = sig - DelayN.ar(sig, maxdelaytime: 0.01, delaytime: (p*0.01)+(0.5/48000));
		sig = sig * EnvGen.ar(Env.adsr(0.0, 0.3, 0.666, 0.005), gate: gate, doneAction:2);
		//amp = Latch.kr(gate, gate) * amp;
		sig = amp.lag(0.001) * sig * 4 * ampfactor;
		//sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 1.0), gate: gate);
		//no sound must exceed 1.5 sec
		//sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
		sig = LPF.ar(HPF.ar(sig, 80.0), 20000.0).tanh; // output filtering and protection
		Out.ar(0, [sig, sig]);
		Out.ar(2, [sig, sig]);
		Out.ar(4, [sig, sig]);
		Out.ar(6, [sig, sig]);
	}).add;

	SynthDef(\addsound, {
		| out = 0, bufnum, amp = 0.5, minwaittime = 0.5, maxwaittime = 1.5, cutoff = 500 |
		var sig, deltime;
		deltime = Rand(minwaittime, maxwaittime);
		sig = DelayN.ar(PlayBuf.ar(1, bufnum, doneAction:0)!2, deltime, deltime);
		sig = LPF.ar(sig, cutoff);
		sig = sig * Env.perc(deltime + 0.25, curve:8).kr(doneAction:2);
		sig = sig * amp;
		sig = LPF.ar(HPF.ar(sig, 80.0), 20000.0).tanh; // output filtering and protection
		Out.ar(out, sig);
	}).add;

	~voices = 5;
	v = Voicer.new(~voices, "sample_player");

	SynthDef(\onsetDetection, {
		|tbThreshDB=0.0, fbThreshDB=0.0,  relaxtime=1.0, floorDB=(20.0.neg), mingap=22, medianspan=22, velDelay=0.006, tbRefPeriod=0.03, lpf1Freq=25.0, lpf2Freq=25.0, hpfFreq=4000.0, cancelDel=1.0|

		var sigRaw, sig, sighpf, sigsquared, lpf1, derivative, lpf2, tsub, tbTrig, chain, fbTrigKR, fbTrigAR, vel;
		var sampleDur = 1.1/SampleRate.ir; // duration of one audio sample, plus 10 percent safety
		var nfft = 256; // FFT size in samples
		var frameDur = (nfft/SampleRate.ir)*1.1; // duration of one fft frame in seconds, plus safety of 10 percent. 5.4ms at 48kHz and 256samp fft size.
		var minusTwoPiT = 2.0.neg*pi/SampleRate.ir; // pre-computation
		var lpf1CoeffA = exp(lpf1Freq*minusTwoPiT); // feedback coefficient for 1st order lowpass filter (leaky integrator) (lpf1)
		var lpf2CoeffA = exp(lpf2Freq*minusTwoPiT); // feedback coefficient for 1st order lowpass filter (leaky integrator) (lpf2)
		var lpf1CoeffAm = 1.0-lpf1CoeffA; // pre-computation
		var lpf2CoeffAm = 1.0-lpf2CoeffA; // pre-computation

		sigRaw = SoundIn.ar([0,1,2,3]); // 4 input channels
		sig = sigRaw.sum; // downmix to mono

		//=== TBOD ===
		sighpf = HPF.ar(LPF.ar(sig, 16000.0), hpfFreq); // Highpass Filter. Turchet2018: 4000 for conga, 7500 for bongo/djembe/cajon
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
		fbTrigKR = Onsets.kr(chain, fbThreshDB.dbamp, \rcomplex, relaxtime: relaxtime, floor: floorDB.dbamp, mingap: mingap, medianspan: medianspan); // rcomplex is best. if it takes up too much cpu, then use power.
		fbTrigAR = T2A.ar(fbTrigKR, offset: 0);
		SendTrig.ar(fbTrigAR, 2); // send FBOD trigger to language. ID 2 means FBOD.

		//=== FAC: false alarm cancellation ===
		SendTrig.ar(DelayN.ar(tbTrig, 0.1, cancelDel*frameDur), 0); // send FBOD cancel trigger to language. ID 0 means FBOD cancel (TBOD false alarm, FBOD correct rejection)

		//=== VD: velocity detection ===
		vel = RunningMax.ar(sig.abs, DelayN.ar(fbTrigAR, 0.1, velDelay+sampleDur)); // running max of input. reset delayed after FBOD trigger + 1 sample safety.
		SendTrig.ar(DelayN.ar(fbTrigAR, 0.1, velDelay), 3, value: vel); // send velocity value to language. Waiting time is set via velDelay.

	}).add;



	//init
	//~trigflag = false;
	~ampfactor = 60.0.neg.dbamp; // master volume initial value (can be set from GUI)
	~ampfactorcat = 60.0.neg.dbamp; // cat volume initial value (can be set from GUI)
	~onset_sum = 0;
	~globalvel = 0.0;


	// function to trigger voice
	~voicetrigger = { |amp=0.01|
		var lastvoice; // variable to store voice that is returned by this function
		
		// trigger new voice
		lastvoice = v.trigger(1, 1, [\amp, amp, \gate, 1, \bufnum, f.value(~sound), \ampfactor, ~ampfactor]);

		//~lastvoice =
		// v.trigger(1, 1, [\amp, amp, \ampfactor, ~ampfactor, \gate, 1, \bufnum, f.value(~sound)]);
		//~trigflag = true;

		//cat sounds
		if(~addsound == true){
			"cat".postln;
			~onset_sum = ~onset_sum + 1;

			//conitinuous impacts
			fork{
				5.wait;
				~onset_sum = 0;
			};

			if((~soundstopped == 0) && (~onset_sum < 5)){
				~soundstopped = 1;
				if(x.isPlaying == false){
					fork{
						if(0.5.coin == true){
							x = Synth(\addsound, [\bufnum, f.value(~soundcat_sum), \amp, ~ampfactorcat]);
						};
						rrand(5,8).wait;
						~soundstopped = 0;
					}
				};
			};
		};


		//multiple impacts
		if((~addsound == true) && (~onset_sum > 5)){
			if(x.isPlaying == false){
				10.do{~onset_sum.postln};
				~onset_sum = 0;
				x = Synth(\addsound, [\bufnum, f.value(~soundcat_sum), \amp, ~ampfactorcat]);
				~onset_sum = 0;
			}
		};

		// return this when evaluating the function:
		lastvoice;

	};


	// Variables for sound triggering logic
	// ~timeStampOld = 0.0;
	~tbodTriggered = false;
	~fbodAgrees = false;
	~glassflag = true; //glass broke


	// Receive OSC from synth
	a = OSCFunc({ |msg, time|
		var id = msg[2];
		var val = msg[3];
		var timeStampNew = time;
		// var timeMsg = ( 1000.0 * (timeStampNew-~timeStampOld) ).round(0.1).asString;
		// ~timeStampOld = timeStampNew;

		~globalvel = val;
		
		//sound triggering logic
		switch (id,
			0, { // False Alarm Cancellation
				if(~tbodTriggered&&~fbodAgrees.not, {
					~lastvoice.set([\gate, 0]);
					("No confirmation from FBOD. --> Onset cancelled.").postln;
				});
				~tbodTriggered = false;
				~fbodAgrees = false;
			},
			1, { // TBOD trigger new
				~lastvoice = ~voicetrigger.();
				("TBOD triggers new onset.").postln;
				~tbodTriggered = true;
				~fbodAgrees = false;
			},
			2, { // FBOD trigger
				if( ~tbodTriggered, { // agree
					~fbodAgrees = true;
					("FBOD agrees with TBOD.").postln;
				}, { // trigger new
					~lastvoice = ~voicetrigger.();
					("FBOD triggers new onset.").postln;
				});
			},
			3, { // Velocity update
				~lastvoice.set([\amp, val]);
				("Velocity update:"+val).postln;
			};
		);

		//break glass
		~globalvel = val;
		if(~outcome == true&&~glassflag == true){
			if(~globalvel > 0.1){
				~sound = ~soundcat_sum;
				v.trigger(1, 1, [\amp, val, \gate, 1, \bufnum, f.value(~soundcat_sum), \ampfactor, ~ampfactor]);
				~glassflag = false;
			};
		};


	},'/tr', s.addr);


	// receive OSC from GUI: define function
	~oscSet = {|synth, key, addr, printflag=true|
		OSCFunc({|msg, time|
			var val = msg[1];
			if(printflag, {
				// ("OSC incoming:"+time+key+val).postln;
				("OSC incoming:"+key+val).postln;
			});
			x.set(key, val);
		},addr);
	};

	// receive OSC from GUI: create receivers
	~oscSet.(x, \tbThreshDB, '/tbod/threshDB');
	~oscSet.(x, \fbThreshDB, '/fbod/threshDB');
	~oscSet.(x, \relaxtime, '/fbod/relaxtime');
	~oscSet.(x, \floorDB, '/fbod/floorDB');
	~oscSet.(x, \mingap, '/fbod/mingap');
	~oscSet.(x, \medianspan, '/fbod/medianspan');
	~oscSet.(x, \velDelay, '/vel/delay');
	~oscSet.(x, \tbRefPeriod, '/tbod/refPeriod');
	~oscSet.(x, \lpf1Freq, '/tbod/lpf1Freq');
	~oscSet.(x, \lpf2Freq, '/tbod/lpf2Freq');
	~oscSet.(x, \hpfFreq, '/tbod/hpfFreq');
	// put other parameters of gui here...


	// receive OSC from GUI: define function
	~oscSetVar = { |key, addr, func, printflag=true|
		OSCFunc({|msg, time|
			var val = msg[1];
			if(printflag, {
				// ("OSC incoming:"+time+key+val).postln;
				("OSC incoming:"+key+val).postln;
			});
			func.(val);
		},addr);
	};

	// receive OSC from GUI: create receivers
	~oscSetVar.(\master, '/master/main', {|val| ~ampfactor=val.dbamp});
	~oscSetVar.(\cat, '/master/cat', {|val| ~ampfactorcat=val.dbamp});



	1.wait;

	x = Synth(\onsetDetection);

	0.5.wait;

	// request parameters from GUI
	n = [ NetAddr("192.168.0.101", 57120), NetAddr("192.168.0.102", 57120) ]; // set GUI addresses
	n.do{|item| item.sendMsg(\bela, \booted) }; // send request via OSC to all addresses



};


ServerQuit.add({ 0.exit }); // quit if the button is pressed