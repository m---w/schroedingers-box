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

	SynthDef(\tba_fba, { |tba_hi = 1e-3, tba_lo = 1e-3, fba_thres = 1 |
		var sigRaw, sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tsub, vel, ttrigdel, ttrigdelfba;
		var chain, onsets;
		sigRaw = SoundIn.ar((0..3)); // 4 input channels
		sig = sigRaw.sum; // downmix to mono
		//===TBA===
		sighpf = HPF.ar(sig, 4000); // Highpass Filter. Turchet2018: 4000 for conga, 7500 for bongo/djembe/cajon
		sigsquared = sighpf.squared; // Squaring (get signal energy)
		lpf1 = LPF.ar(sigsquared, 25); // Smoothing 1. Turchet2018: 25
		derivative = Slope.ar(lpf1); // 1st derivative = slope
		lpf2 = LPF.ar(derivative, 100); // Smoothing 2. Turchet2018: 25
		// tsub = (0.01 * lpf1 - lpf2).max(0); // trend subtraction (inspired from Coyote)
		tsub = lpf2 - Median.ar(64, lpf2); // trend subtraction (inspired from Turchet2018: length 65 samples)
		// ttrig = Schmidt.ar(tsub, tba_hi, tba_lo); // thresholding with high and low threshold
		ttrig = Trig.ar(tsub-tba_hi, 0.0054); // simple thresholding, trigger lasts for one FFT block (256/48000 s)
		SendTrig.ar(ttrig, 1); // send TBA onset trigger to language. ID 0 means TBA.
		//===FBA===
		chain = FFT(LocalBuf(256), sig, hop: 0.25, wintype: 1); // Turchet2018: winsize 256, hopsize 64
		onsets = Onsets.kr(chain, fba_thres, \rcomplex, relaxtime: 1, floor: 0.1, mingap: 10, medianspan: 11); // rcomplex is best. if it takes up too much cpu, then use power.
		SendTrig.kr(onsets, 2, ttrig+onsets); // send FBA onset trigger to language. ID 1 means FBA. Value: 1 means new onset (TBA miss, FBA hit), 2 means onset confirmation (TBA hit, FBA hit).
		ttrigdelfba = 1.0-Trig.ar(onsets, 0.0054); // delay trigger by one fft block (happens to be 6ms, so can be reused)
		vel = RunningMax.ar(sighpf.abs, ttrigdelfba); // running max of highpass-filtered input. reset with each trigger.
		SendTrig.ar(1.0-ttrig-ttrigdelfba, 0); // send FBA cancel trigger to language. ID 0 means FBA cancel (TBA false alarm, FBA correct rejection)
		// ttrigdelfba = DelayN.ar(onsets, 0.006, 0.006); // wait 6ms after triggering, to get velocity
		SendTrig.ar(ttrigdelfba, 3, value: vel); // send velocity value to language
	}).add;

	//init
	~trigflag = false;
	~ampfactor = 1;
	~ampfactorcat = 1;
	~onset_sum = 0;
	~velfortobreak = 0;

// function to trigger voice
	~voicetrigger = {|amp=0.01|
		// trigger new voice
		v.trigger(1, 1, [\amp, amp, \ampfactor, ~ampfactor, \gate, 1, \bufnum, f.value(~sound)]);


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
				if(~velfortobreak > 0.1){
					~sound = ~soundcat_sum;
				};
			};
		};

	//receive OSC from synth
	a = OSCFunc({ arg msg, time;
		var val, tb_trigval, fb_trigval, sp, vel, bufnum, id;
		[time, msg].postln;
		tb_trigval = 0;
		fb_trigval = 0;
		fork{
			//	vel = msg[3];
			//~velfortobreak = vel;
			//vel.postln;

			//break glass
			//if(~outcome == true){
			//if(~velfortobreak > 0.1){
			//~sound = ~soundcat_sum;
			//	};
			//};


			id = msg[2];
			val = msg[3];
			switch (id,
				0, { // FBA Cancel
					//if(~trigflag == true){
						~lastvoice.set([\gate, 0]);
						"FBA cancels TBA.".postln;
						//}
				},
				1, { // TBA trigger
					//if(~trigflag == false){
						~lastvoice = ~voicetrigger.();
						"TBA triggers new onset.".postln;
					//}
				},
				2, { // FBA trigger
					if( val==1.0,
						{ // new onset
							//if(~trigflag == false){
								~lastvoice = ~voicetrigger.();
								"FBA triggers new onset.".postln;
							//}
						},
						{ // existing onset
							"FBA agrees with TBA.".postln;
						}
					);
				},
				3, { // Velocity update
					//if(~trigflag == true){
						~lastvoice.set([\amp, val]);
						("Velocity update:"+val).postln;
					//}
				},
			);

			~trigflag = false;
			
			/* if((msg[2] == 0) && (~trigflag == false)){
				~lastvoice = v.trigger(1, 1, [\amp, 0.001, \ampfactor, ~ampfactor, \gate, 1, \bufnum, f.value(~sound)]);
				~trigflag = true;
			};
			//if(msg[2] == 2){~lastvoice.set([\amp,msg[3]]); 20.do{[vel, "RMAX MAP TBA"].postln}};	
			if(msg[2] == 3){~lastvoice.set([\amp,msg[3]]); 20.do{[vel, "RMAX MAP FBA"].postln}};
			0.006.wait;
			fb_trigval = 0;
			if((msg[2] == 1) && (~trigflag == true)){
				fb_trigval = 1;
				"FBA_agrees".postln;
			};
			if((fb_trigval == 0) && (~trigflag == true)){~lastvoice.set([\gate,0]); "FBA_disagrees".postln;};
			
			if((msg[2] == 1) && (~trigflag == false)){
				~lastvoice = v.trigger(1, 1, [\amp, 0.001, \ampfactor, ~ampfactor, \gate, 1, \bufnum, f.value(~sound)]);
			};
			
			~trigflag = false;	

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
				if(msg[3] > 0.1){
					~sound = ~soundcat_sum;
				};
				};*/
		}
		
	},'/tr', s.addr);

	//thresh control
	OSCFunc({ arg msg, time;
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
		
	},'/thres/fba_thres_db');

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

	q = Synth(\tba_fba);
};



ServerQuit.add({ 0.exit }); // quit if the button is pressed
