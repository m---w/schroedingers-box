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
g.plot;


//:

//Implementation: HARD REAL-TIME ONSET DETECTION OF PERCUSSIVE SOUNDS ==> Luca Turchet

play{
	var sig, initsig, sigsquared, env, envtrue, lpf1, lpf2;
	envtrue = Env.perc(0.000, 0.03, curve:'sin').ar(doneAction:0);

	//initial sig
	sig = envtrue * PinkNoise.ar(1);
	initsig = sig;

	//HPF
	sig = HPF.ar(sig, 100);
	
	//squared
	sigsquared = sig.squared;;

	//smoothing
	lpf1 = LPF.ar(sigsquared, 25);

	//

	[sigsquared, envtrue]
}

//:

{PinkNoise.ar().squared * EnvGen.kr(Env.perc(0.000, 0.03, curve:'sin'))}.plot(0.2)
{EnvGen.kr(Env.perc(0.000, 0.03, curve:'sin'))}.plot(0.2)