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
	//sound1
	~sound1var1 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var01.wav", channels:1);
	~sound1var2 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var02.wav", channels:1);
	~sound1var3 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var03.wav", channels:1);
	~sound1var4 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var04.wav", channels:1);
	~sound1var5 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var05.wav", channels:1);

	//sound2
	~sound2var1 = Buffer.readChannel(s, "./sounds/kagelo01.wav", channels:1);
	~sound2var2 = Buffer.readChannel(s, "./sounds/kagelo02.wav", channels:1);

	//sound3
	~sound3var1 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var1.wav", channels:1);
	~sound3var2 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var2.wav", channels:1);
	~sound3var3 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var3.wav", channels:1);

	//sound4
	~sound4var1 = Buffer.readChannel(s, "./sounds/timpani_bends1_var1.wav", channels:1);
	~sound4var2 = Buffer.readChannel(s, "./sounds/timpani_bends1_var2.wav", channels:1);
	~sound4var3 = Buffer.readChannel(s, "./sounds/timpani_bends1_var3.wav", channels:1);
	~sound4var4 = Buffer.readChannel(s, "./sounds/timpani_bends1_var4.wav", channels:1);
	~sound4var5 = Buffer.readChannel(s, "./sounds/timpani_bends1_var5.wav", channels:1);
	~sound4var6 = Buffer.readChannel(s, "./sounds/timpani_bends1_var6.wav", channels:1);

	//sound5
	~sound5var1 = Buffer.readChannel(s, "./sounds/35dogtoy_var1.wav", channels:1);
	~sound5var2 = Buffer.readChannel(s, "./sounds/35dogtoy_var2.wav", channels:1);

	//sound6
	~sound6var1 = Buffer.readChannel(s, "./sounds/wood_hitting01.wav", channels:1);
	~sound6var2 = Buffer.readChannel(s, "./sounds/wood_hitting02.wav", channels:1);
	~sound6var3 = Buffer.readChannel(s, "./sounds/wood_hitting03.wav", channels:1);
	//cat
	~soundstopped = 0; //do not play cat on every detected impact
	~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
	~sound6cat1 = Buffer.read(s, "./sounds/cat_01.wav");
	~sound6cat2 = Buffer.read(s, "./sounds/cat_02.wav");
	~sound6cat3 = Buffer.readChannel(s, "./sounds/cat_03.wav", channels:1);
	~sound6cat4 = Buffer.readChannel(s, "./sounds/cat_04.wav", channels:1);
	~sound6cat5 = Buffer.read(s, "./sounds/cat_05.wav");
	~sound6cat6 = Buffer.read(s, "./sounds/cat_06.wav");
	~soundcat_sum = [~sound6cat1, ~sound6cat2, ~sound6cat3, ~sound6cat4, ~sound6cat5, ~sound6cat6];
	
	
	
	//~sound = [~sound1var1, ~sound1var2, ~sound1var3];//, ~sound1var4, ~sound1var5];
	
	~button = 0;
	OSCdef(\next_sound, { | msg, time, button = 0 |
		[time, msg].postln;
		//msg[1].postln;
		msg.postln;

		//direct sample choosing via numberbox
		if(msg[1] == 'sam_num'){
			~button = 0;
			~button = msg[2];
			msg[2].postln;
		};		
		
		//counter_via_button_hits
		if(msg[1] == 1.0){
			~button = ~button + 1;
		};
		if(~button == 0){"press the button to start".postln};
		
		//sound1
		if(~button == 1){~sound = [~sound1var1, ~sound1var2, ~sound1var3, ~sound1var4, ~sound1var5]};
		
		//sound2
		if(~button == 2){~sound = [~sound2var1, ~sound2var2]};
		
		//sound3
		if(~button == 3){~sound = [~sound3var1, ~sound3var2, ~sound3var3];};

		//sound4
		if(~button == 4){~sound = [~sound4var1, ~sound4var2, ~sound4var3, ~sound4var4, ~sound4var5, ~sound4var6]};

		//sound5
		if(~button == 5){~sound = [~sound5var1, ~sound5var2]};

		//sound6
		if(~button == 6){~sound = [~sound6var1, ~sound6var2, ~sound6var3];
		};

		//finish
		if(~button == 10){s.freeAll};
		
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
		| gate = 1, amp = 0.1, bufnum = 0 |
		var sig, env, out;
		sig = PlayBuf.ar(numChannels:1, bufnum:bufnum, rate: Rand(0.9, 1.1), trigger: gate);
		p=1.0.linrand;
		sig = sig - DelayN.ar(sig, maxdelaytime: 0.01, delaytime: (p*0.01)+(0.5/48000));
		sig = sig * EnvGen.ar(Env.adsr(0.0, 0.3, 0.666, 2), gate: gate, doneAction:2);
		//amp = Latch.kr(gate, gate) * amp;
		sig = amp * sig;
		//sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 1.0), gate: gate);
		//no sound must exceed 1.5 sec
		//sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
		Out.ar(7, [sig, sig])
	}).add;

	v = Voicer.new(5, "sample_player");

	SynthDef(\tba_fba, { |tba_hi = 1e-3, tba_lo = 1e-3, fba_thres = 1 |
		var sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend, vel, temp, trigtemp;
		var chain, onsets, pips, ftrig, fthres;
		sig = SoundIn.ar(0);
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
		vel = RunningMax.ar(sig.abs, ttrig);
		tsend = SendTrig.kr(A2K.kr(ttrig), 0, value:vel);
		//===FBA===
		chain = FFT(LocalBuf(256), sig);
		fthres = fba_thres;
		onsets = Onsets.kr(chain, fthres, \power);
		//vel track test
		trigtemp = ttrig + onsets;
		vel = RunningMax.ar(vel + sig.abs, trigtemp);
		ftrig = SendTrig.kr(onsets, 1, value:vel);
	}).add;

	//Vel track tests
	a = OSCFunc({ arg msg, time;
		var val, tb_trigval, fb_trigval, sp, vel, bufnum;
		[time, msg].postln;
		tb_trigval = 0;
		fb_trigval = 0;
		//vel = 0;
		fork{
			vel = msg[3];
			vel.postln;
			v.trigger(1, 1, [\amp, vel.linlin(0.0, 1.0, 0.0, 1.0), \gate, 1, \bufnum, f.value(~sound)]);  
			0.006.wait;
			//msg[2].postln;
			fb_trigval = 0;
			if(msg[2] == 1){
				fb_trigval = 1;
				"FBA_agrees".postln;
			};//sp.set has to change for the real thing
			if(fb_trigval == 0){v.set([\gate,0]); "FBA_disagrees".postln};

			//cat sounds
			if(~button == 6){
				"cat".postln;
				~onset_sum = ~onset_sum + 1;
				
				//conitinuous impacts
				fork{5.wait; 
					~onset_sum = 0;
				};
				
				if((~soundstopped == 0) && (~onset_sum < 5)){
				
					~soundstopped = 1;
					fork{
						if(0.5.coin == true){
				{play{Out.ar(7, PlayBuf.ar(1, f.value(~soundcat_sum), doneAction:2)/*ENVELOPE MULTIPLY*/)}}.defer(rrand(0.5, 1.5));
					};
				rrand(5,8).wait;
				~soundstopped = 0;
					}
			};
		};
			
			//multiple impacts 
			if((~button == 6) && (~onset_sum > 5)){
			{
				10.do{~onset_sum.postln};
				~onset_sum = 0;
				play{
					Out.ar(7, PlayBuf.ar(1, f.value(~soundcat_sum), doneAction:2))/*ENVELOPE MULTIPLY*/
				};
			}.defer(rrand(0.5, 1.5));
			//1.wait;
			~onset_sum = 0;
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

	

	1.wait;

	q = Synth(\tba_fba);
};



ServerQuit.add({ 0.exit }); // quit if the button is pressed
