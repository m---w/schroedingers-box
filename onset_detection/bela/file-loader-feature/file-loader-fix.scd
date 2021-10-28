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
		var sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend, vel, temp, trigtemp, ttrigdel, ttrigdelfba;
		var chain, onsets, pips, ftrig, fthres;
		sig = SoundIn.ar((0..3)).sum;
		//===TBA===
		sighpf = HPF.ar(sig, 4000);
		sigsquared = sighpf.squared;
		lpf1 = LPF.ar(sigsquared, 25);
		derivative = Slope.ar(lpf1);
		lpf2 = LPF.ar(derivative, 100);
		tsub = 0.01 * lpf1 - lpf2;
		tsub = tsub.max(0);
		tthres = tba_hi;//1e-3;
		ttrig = Schmidt.ar(tsub, tthres, tthres);
		ttrigdel = DelayN.ar(ttrig, 0.006, 0.006);
		vel = RunningMax.ar(sig.abs, ttrigdel);
		tsend = SendTrig.kr(A2K.kr(ttrig), 0, value:vel);
		//tsend = SendTrig.kr(A2K.kr(ttrigdel), 2, value:vel);	
		//===FBA===
		chain = FFT(LocalBuf(256), sig, wintype:1);
		fthres = fba_thres;
		onsets = Onsets.kr(chain, fthres, \power);
		//vel track test
		ttrigdelfba = DelayN.ar(onsets, 0.006, 0.006);//ttrig + onsets;
		vel = RunningMax.ar(sig.abs, ttrigdelfba);
		tsend = SendTrig.kr(A2K.kr(ttrigdelfba), 3, value:vel);
		ftrig = SendTrig.kr(onsets, 1, value:vel);
	}).add;

	//init
	~trigflag = false;
	~ampfactor = 1;
	~ampfactorcat = 1;
	~onset_sum = 0;
	
	a = OSCFunc({ arg msg, time;
		var val, tb_trigval, fb_trigval, sp, vel, bufnum;
		[time, msg].postln;
		tb_trigval = 0;
		fb_trigval = 0;
		fork{
			vel = msg[3];
			//vel.postln;

			//break glass
			if(~outcome == true){
				if(msg[3] > 0.1){
					~sound = ~soundcat_sum;
				};
			};
			
			
			if((msg[2] == 0) && (~trigflag == false)){
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
			};
		}
		
	},'/tr', s.addr);


	//thresh control
	OSCFunc({ arg msg, time;
		var val;
		[time, msg].postln;
		val = msg[1];
		val.postln;
		q.set(\tba_hi, val);
		
	},'/thres/tba_hi');

	OSCFunc({ arg msg, time;
		var val;
		[time, msg].postln;
		val = msg[1];
		val.postln;
		q.set(\tba_lo, val);
		
	},'/thres/tba_lo');

	OSCFunc({ arg msg, time;
		var val;
		[time, msg].postln;
		val = msg[1];
		val.postln;
		q.set(\fba_thres, val);
		
	},'/thres/fba_thres');

	OSCFunc({ arg msg, time;
		var val;
		[time, msg].postln;
		val = msg[2];
		val.postln;
		if(msg[1] == \main){
			~ampfactor = val;
		};
		if(msg[1] == \cat){
			~ampfactorcat = val;
		};

	},'/master');

	

	1.wait;

	q = Synth(\tba_fba);
};



ServerQuit.add({ 0.exit }); // quit if the button is pressed
