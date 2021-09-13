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

play{ | rt = 0.1 |
	var sig, sigsquared, env;
	sig = Env.perc(0.000, 0.03, curve:'sin').kr(doneAction:0) * PinkNoise.ar(2);
	sigsquared = sig.squared;
	env = Amplitude.ar(sigsquared, 0.000, rt);
	[sigsquared, env];
}

//: then plot it => different amp values
~g1 = Buffer.read(s, "/Users/jsk/Desktop/HWR2.wav");
~g1.plot;

