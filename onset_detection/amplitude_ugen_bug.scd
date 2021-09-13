//: when plotted amplitude envelope has same amp as signal

plot{ | rt = 0.1 |
	var sig, sigsquared, env;
	sig = Env.perc(0.000, 0.03, curve:'sin').kr(doneAction:0) * PinkNoise.ar(2);
	sigsquared = sig.squared;
	env = Amplitude.ar(sigsquared, 0.000, rt);
	[sigsquared, env];
}

//: exactly the same code but instead of plot => play

s.record("~/Desktop/HWR2.wav");
//:
play{ | rt = 0.05 |
	var sig, sigsquared, env, envtrue;
	envtrue = Env.perc(0.000, 0.03, curve:'sin').ar(doneAction:0);
	sig = envtrue * PinkNoise.ar(1);
	sigsquared = sig.abs;
	//env = Lag.ar(sigsquared, 0.01).max(sigsquared).sqrt;//Amplitude.ar(sigsquared, 0.000, rt);
	//env = Integrator.ar(sig).sqrt;
	//env = EnvFollow.ar(sigsquared, 0.99);
	env = Amplitude.ar(sigsquared, 0.0, 0.05);
	[env, sigsquared];
	//[sigsquared, env];
}

//: then plot it => different amp values
s.record("~/Desktop/HWR2.wav");
g = Buffer.read(s, "/Users/jsk/Desktop/HWR2.wav");
g.plot(discrete:true);









//This works
//================================================================================================
//:
~sample = Buffer.readChannel(s,"/Users/jsk/Desktop/schroedingers_box/Mallet_impacts/hardest.wav", 40000, -1900, channels:[0]);

//:
//Implementation: HARD REAL-TIME ONSET DETECTION OF PERCUSSIVE SOUNDS ==> Luca Turchet

play{
	var sig, initsig, sigsquared, env, envtrue, lpf1, lpf2, derivative, trig, output, thres;
	envtrue = Env.perc(0.000, 0.03, curve:'sin').ar(doneAction:0);

	//initial sig
	//sig = envtrue * PinkNoise.ar(1);
	sig = PlayBuf.ar(1, ~sample, loop:1);
	initsig = sig;

	//HPF
	sig = HPF.ar(sig, 4000);
	
	//squared
	sigsquared = sig.squared;

	//smoothing lpf1
	lpf1 = LPF.ar(sigsquared, 25);

	//derivative computation
	derivative = Slope.ar(lpf1);

	//no need to half wave rectification? [deriative, lpf2]

	//smoothing lpf2
	lpf2 = LPF.ar(derivative, 100);

	thres = MouseX.kr(0.0, 1.0);
	thres.poll;
	trig = Schmidt.ar(lpf2, thres, thres);
	trig.poll;

	output = Saw.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.4, 0.2), gate:trig));
	
	//[derivative, lpf2, sig];
	[initsig * 0.2, output];
	//Out.ar(0, output);
}//.plot(0.2)//.plot(duration:0.2)

//:
