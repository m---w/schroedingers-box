// =====================================================================
// SuperCollider Workspace
// =====================================================================

~bus = Bus.audio(s, 1);
//:
play{
	var sig = In.ar(4, 1);
	sig.poll;
	//Out.ar(0, sig)
	
}
//:
play{
	var sig = SinOsc.ar(666);
	Out.ar(~bus, sig);
};


//:
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
	
	//sound7
	~sound7var1 = Buffer.read(s, "./sounds/impact.wav");
	~sound7var2 = Buffer.read(s, "./sounds/impact1.wav");
	~sound7var3 = Buffer.read(s, "./sounds/impact2.wav");
	~sound7var4 = Buffer.read(s, "./sounds/impact3.wav");
	~sound7var5 = Buffer.read(s, "./sounds/impact4.wav");
	~sound7var6 = Buffer.read(s, "./sounds/impact5.wav");	
	
	//~sound = [~sound1var1, ~sound1var2, ~sound1var3];//, ~sound1var4, ~sound1var5];
	s.newBusAllocators;
	~bus = Bus.audio(s, 1);
	
			SynthDef(\tba_fba, { |tba_hi = 1e-3, tba_lo = 1e-3, fba_thres = 1 |
		var sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend, vel, temp, trigtemp;
		var chain, onsets, pips, ftrig, fthres;
		var businput, amptrack, reduction;
		
		businput = In.ar(~bus, 1);
		businput.poll;
		amptrack = Amplitude.kr(businput, 0.001, 1);
		//amptrack.poll;
		reduction = amptrack.ampdb - 60.neg;
		reduction = reduction.dbamp.max(1);
		//reduction.poll;
		sig = SoundIn.ar(0);
		
		//===TBA===
		sighpf = HPF.ar(sig, 4000);
		sigsquared = sighpf.squared;
		lpf1 = LPF.ar(sigsquared, 25);
		derivative = Slope.ar(lpf1);
		lpf2 = LPF.ar(derivative, 100);
		tsub = 0.01 * lpf1 - lpf2;
		tsub = tsub.max(0);
		tthres = tba_hi * reduction;//1e-3;
		ttrig = Schmidt.ar(tsub, tthres, tthres);
		vel = RunningMax.ar(sig.abs, ttrig);
		tsend = SendTrig.kr(A2K.kr(ttrig), 0, value:vel);
		//===FBA===
		chain = FFT(LocalBuf(256), sig);
		fthres = fba_thres * reduction;
		onsets = Onsets.kr(chain, fthres, \power);
		//vel track test
		trigtemp = ttrig + onsets;
		vel = RunningMax.ar(vel + sig.abs, trigtemp);
		ftrig = SendTrig.kr(onsets, 1, value:vel);
	}).add;

	1.wait;

	q = Synth(\tba_fba);

	1.wait;
//:
	SynthDef(\sample_player,{
		| bus=0, gate = 1, amp = 0.1, bufnum = 0 |
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
		Out.ar(outbus, sig);
		//Out.ar(0, sig);
		//Out.ar(6, [sig, sig]);
		//Out.ar(0, [sig, sig]);
		//Out.ar(2, [sig, sig]);
		//Out.ar(4, [sig, sig]);
		
	}).add;
//:
	//10.do{Synth(\sample_player); 0.5.wait;}

};

v = Voicer.new(5, "sample_player", bus:0);
v.trigger(1,1, [\amp, 0.5, \gate, 1, \bus,~bus])


s.meter(s, 2, ~bus)


PeakMonitor(4)  // monitor 2 channels starting with 4

// or
PeakMonitor(Bus(\audio, 0, 8, s))

//:
play{
	var sig = In.ar(4, 1);
	sig.poll;
	Out.ar(0, sig)
	
}