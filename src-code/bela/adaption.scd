/*
Schroedinger's Box
SuperCollider Patch for Bela
2021 Jason Svoronos-Kanavas, Marian Weger
*/

//Onsets \power, 256 FFT, 1.5 sec rel time env of playback sound, minigap:30

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

	OSCdef(\next_sound, { | msg, time, button = 0 |
		[time, msg].postln;
		msg.postln;
		//direct sample choosing via numberbox
		if(msg[1] == 'sam_num'){
			~button = 0;
			~button = msg[2];
			msg[2].postln;
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
			arr.postln;
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
		Out.ar(out, sig);
	}).add;

	v = Voicer.new(5, "sample_player");

	SynthDef(\tba_fba, { |tba_hi=(40.0.neg), fba_thres=0.0,  relaxtime=1.0, floor=0.1, mingap=22, medianspan=22, velDelay=0.006, tbRefPeriod=0.03, lpf1Freq=25.0, lpf2Freq=25.0, hpfFreq=4000.0|
		var sigRaw, sig, sighpf, sigsquared, lpf1, derivative, lpf2, tsub, tbTrig, tbTrigLong, chain, fbTrig, fbTrigShort, fbTrigLong, fbTrigLongInv, tbTrigDelShort, facTrig, vel;
		var sampleDur = 1.0/SampleRate.ir; // duration of one audio sample
		var nfft = 256; // FFT size in samples
		var frameDur = (nfft/SampleRate.ir).roundUp(1.0e-4); // duration of one fft frame in seconds, rounded up on grid of 0.1ms. 5.4ms at 48kHz and 256samp fft size.
		var minusTwoPiT = 2.0.neg*pi/SampleRate.ir; // pre-computation
		var lpf1CoeffA = exp(lpf1Freq*minusTwoPiT); // feedback coefficient for 1st order lowpass filter (leaky integrator) (lpf1)
		var lpf2CoeffA = exp(lpf2Freq*minusTwoPiT); // feedback coefficient for 1st order lowpass filter (leaky integrator) (lpf2)
		var lpf1CoeffAm = 1.0-lpf1CoeffA; // pre-computation
		var lpf2CoeffAm = 1.0-lpf2CoeffA; // pre-computation
		sigRaw = SoundIn.ar([0,1,2,3]); // 4 input channels
		sig = sigRaw.sum; // downmix to mono
		//=== TBOD ===
		sighpf = HPF.ar(sig, hpfFreq); // Highpass Filter. Turchet2018: 4000 for conga, 7500 for bongo/djembe/cajon
		sigsquared = sighpf.squared; // Squaring (get signal energy)
		lpf1 = Integrator.ar(lpf1CoeffAm*sigsquared, lpf1CoeffA); // Smoothing 1. Turchet2018: 25
		derivative = Slope.ar(lpf1); // 1st derivative = slope
		lpf2 = Integrator.ar(lpf2CoeffAm*derivative, lpf2CoeffA); // Smoothing 2. Turchet2018: 25
		// tsub = (0.01 * lpf1 - lpf2).max(0); // trend subtraction (inspired from Coyote)
		tsub = lpf2 - Median.ar(64, lpf2); // trend subtraction (inspired from Turchet2018: length 65 samples)
		// ttrig = Schmidt.ar(tsub, tba_hi, tba_lo); // thresholding with high and low threshold
		tbTrig = Trig.ar(tsub-tba_hi.dbamp, tbRefPeriod); // simple thresholding, including a refractory period to prevent re-triggering within the given time
		tbTrigLong = Trig.ar(tbTrig, frameDur); // trigger lasts for one FFT block
		SendTrig.ar(tbTrigLong, 1); // send TBOD trigger to language. ID 1 means TBOD.
		//=== FBOD ===
		chain = FFT(LocalBuf(nfft), sig, hop: 0.25, wintype: 1); // Turchet2018: winsize 256, hopsize 64. Wintype 1 is Hann window.
		fbTrig = Onsets.kr(chain, fba_thres.dbamp, \rcomplex, relaxtime: relaxtime, floor: floor, mingap: mingap, medianspan: medianspan); // rcomplex is best. if it takes up too much cpu, then use power.
		fbTrigShort = Trig.ar(K2A.ar(fbTrig), sampleDur); // make sure that fbTrig is audio rate, and only one sample long.
		// SendTrig.ar(K2A.ar(fbTrig), 2, tbTrigLong+fbTrig); // send FBOD onset trigger to language. ID 2 means FBOD. Value: 1 means new onset (TBOD miss, FBOD hit), 2 means onset confirmation (TBOD hit, FBOD hit).
		SendTrig.ar(fbTrigShort-tbTrigLong, 2); // send FBOD onset trigger to language. ID 2 means new onset (TBOD miss, FBOD hit).
		SendTrig.ar(fbTrigShort*tbTrigLong, 4); // send FBOD confirmation trigger to language. ID 4 means onset confirmation (TBOD hit, FBOD hit).
		//=== FAC: false alarm cancellation ===
		fbTrigLong = Trig.ar(fbTrigShort, frameDur); // make FBOD triger 6ms long
		fbTrigLongInv = 1.0 - fbTrigLong; // inverse signal: zero between FBOD and 6ms afterwards, otherwise one.
		tbTrigDelShort = Trig.ar(1.0-tbTrigLong, sampleDur); // TBOD trigger, delayed by 6ms, only one sample long.
		facTrig = tbTrigDelShort * fbTrigLongInv; // triggers 6ms after a TBOD trigger in case of no FBOD trigger within this timeframe.
		SendTrig.ar(facTrig, 0); // send FBOD cancel trigger to language. ID 0 means FBOD cancel (TBOD false alarm, FBOD correct rejection)
		//=== VD: velocity detection ===
		vel = RunningMax.ar(sig.abs, DelayN.ar(fbTrigShort, 0.1, velDelay+sampleDur)); // running max of input. reset delayed after FBOD trigger + 1 sample safety.
		SendTrig.ar(DelayN.ar(fbTrigShort, 0.1, velDelay), 3, value: vel); // send velocity value to language. Waiting time is set via velDelay.
	}).add;



	//init
	//~trigflag = false;
	~ampfactor = 1; // master volume initial value (can be set from GUI)
	~ampfactorcat = 1; // cat volume initial value (can be set from GUI)
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

		if(~outcome == true){
			if(~globalvel > 0.1){
				~sound = ~soundcat_sum;
			};
		};

		// return this when evaluating the function:
		lastvoice;

	};


	// Receive OSC from synth
	a = OSCFunc({ arg msg, time;
		var id, val, tb_trigval, fb_trigval, sp, vel, bufnum;
		[time, msg].postln;
		tb_trigval = 0;
		fb_trigval = 0;
		//vel = 0;
		id = msg[2];
		val = msg[3];
		~globalvel = val;


		//break glass
		if(~outcome == true){
			if(msg[3] > 0.1){
				~sound = ~soundcat_sum;
			};
		};

		//sound triggering logic
		switch (id,
			0, { // FBOD Cancel
				~lastvoice.set([\gate, 0]);
				"FBOD cancels TBOD.".postln;
			},
			1, { // TBOD trigger new
				~lastvoice = ~voicetrigger.();
				"TBOD triggers new onset.".postln;
			},
			2, { // FBOD trigger new
				~lastvoice = ~voicetrigger.();
				"FBOD triggers new onset.".postln;
			},
			4, { // FBOD agree with TBOD
				"FBOD agrees with TBOD.".postln;
			},
			3, { // Velocity update
				~lastvoice.set([\amp, val]);
				("Velocity update:"+val).postln;
			};
		);

		//fork{
		//vel = msg[3];
		//vel.postln;

		//if((msg[2] == 0) && (~trigflag == false)){
		//~lastvoice = v.trigger(1, 1, [\amp, 0.001, \ampfactor, ~ampfactor, \gate, 1, \bufnum, f.value(~sound)]);
		//~trigflag = true;
		//};
		//if(msg[2] == 2){~lastvoice.set([\amp,msg[3]]); 20.do{[vel, "RMAX MAP TBA"].postln}};

		/*
		if(msg[2] == 3){~lastvoice.set([\amp,msg[3]]); 20.do{[vel, "RMAX MAP FBA"].postln}};
		0.006.wait;
		fb_trigval = 0;
		if((msg[2] == 1) && (~trigflag == true)){
		fb_trigval = 1;
		"FBA_agrees".postln;
		};
		*/

		//if((fb_trigval == 0) && (~trigflag == true)){~lastvoice.set([\gate,0]); "FBA_disagrees".postln;};

		//if((msg[2] == 1) && (~trigflag == false)){
		//~lastvoice = v.trigger(1, 1, [\amp, 0.001, \ampfactor, ~ampfactor, \gate, 1, \bufnum, f.value(~sound)]);
		//};
		//}

	},'/tr', s.addr);

	//thresh control
	/*OSCFunc({ arg msg, time;
	var val;
	[time, msg].postln;
	val = msg[1].dbamp;
	val.postln;
	q.set(\tba_hi, val);

	},'/thres/tba_thres_db');

	OSCFunc({ arg msg, time;
	var val;
	[time, msg].postln;
	val = msg[1].dbamp;
	val.postln;
	q.set(\fba_thres, val);

	},'/thres/fba_thres_db');*/


	// receive OSC from GUI: define function
	~oscSet = {|synth, key, addr, printflag=false|
		OSCFunc({|msg, time|
			var val;
			"osc-msg".postln;
			if(printflag, {[time, msg].postln});
			val = msg[1];
			val.postln;
			//synth.set does not work
			//synth.set(key, val);
			x.set(key, val);
		},addr);
	};

	// receive OSC from GUI: create receivers
	~oscSet.(x, \tba_hi, '/thres/tba_thres_db');
	~oscSet.(x, \tba_lo, '/thres/tba_lo');
	~oscSet.(x, \fba_thres, '/thres/fba_thres_db');
	~oscSet.(x, \relaxtime, '/thres/relaxtime');
	~oscSet.(x, \floor, '/thres/floor');
	~oscSet.(x, \mingap, '/thres/mingap');
	~oscSet.(x, \medianspan, '/thres/medianspan');
	~oscSet.(x, \velDelay, '/thres/veldelay');
	// put other parameters of gui here...


	//master faders
	OSCFunc({ arg msg, time;
		var val;
		[time, msg].postln;
		val = msg[1].dbamp;
		val.postln;
		//if(msg[1] == \main){
		~ampfactor = val;
		//};
		/*if(msg[1] == \cat){
		~ampfactorcat = val;
		};*/

	},'/master/main');

	//master faders
	OSCFunc({ arg msg, time;
		var val;
		[time, msg].postln;
		val = msg[1].dbamp;
		val.postln;
		//if(msg[1] == \main){
		~ampfactorcat = val;
		//};
		/*if(msg[1] == \cat){
		~ampfactorcat = val;
		};*/

	},'/master/cat');


	1.wait;

	x = Synth(\tba_fba);
};


ServerQuit.add({ 0.exit }); // quit if the button is pressed