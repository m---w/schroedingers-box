//This works
//================================================================================================
//:
~sample = Buffer.readChannel(s,"/Users/jsk/Desktop/schroedingers_box/Mallet_impacts/hardest.wav", 90000, -48900, channels:[0]);

//:
//Implementation: HARD REAL-TIME ONSET DETECTION OF PERCUSSIVE SOUNDS ==> Luca Turchet

play{
	var sig, initsig, sigsquared, env, envtrue, lpf1, lpf2, derivative, trig, output, thres, impact_amp, tsub;
	envtrue = Env.perc(0.000, 0.03, curve:'sin').ar(doneAction:0);


	//initial sig
	//sig = /*envtrue **/ PinkNoise.ar(LFNoise0.kr(1).range(0.1, 1.0)) * Pulse.kr(1, 0.01);
	//sig = PlayBuf.ar(1, ~sample, loop:1);// * LFNoise0.kr(1).range(0.1, 1.0);
	sig = SoundIn.ar();
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

	//trend subtraction
	tsub = 0.01 * lpf1 - lpf2;
	tsub = tsub.max(0);
	//tsub = 2 * tsub ;
	[lpf2, tsub].poll;
	
	//thres = MouseX.kr(0.0, 1e-8);
	//2.04264e-06 a good value for low signal detection
	thres = MouseX.kr(0.0, 1e-3);
	thres.poll;
	trig = Schmidt.ar(tsub, thres, thres);
	trig.poll;

//super gained compressor raises low amp signals and compresses the high amp ones => very low signals were detected but to low to be audiable (lpf.abs)
//abs makes the envelope positive so it can be mapped to amp
	/*Compander.ar(
			lpf2.abs.poll * 10,
			lpf2.abs * 10,
			thresh: 0.3,
			slopeBelow: 1,
			slopeAbove: 0.5,
			clampTime:  0.01,
			relaxTime:  0.01
		) * 40;*/

	
//PlayBufCF is an extension (it clicked a lot without it): it crossfades when trig
//https://github.com/supercollider-quarks/wslib/tree/master/wslib-classes/Extensions/UGens
	
	output =
	PlayBufCF.ar(
		2,
		~sound,
		trigger: trig,
		doneAction:0, n:4);// * Amplitude.ar(lpf2, 0.01, 4) * 2;
	//Amplitude=long release:4 so it will not stop very fast (according to the input impact) 

	
	//PlayBuf.ar(2, ~sound, trigger: trig.range(-1,1).poll, doneAction:0);
	
	//* EnvGen.ar(Env.perc(0.001, 2), gate:trig, doneAction:2) * impact_amp;
	//Saw.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.4), gate:trig)) * impact_amp;
	 
	//this is just a typical audio compressor for the output sig
	output = Compander.ar(
		output, output,
		thresh:0.7,
		slopeBelow: 1,
		slopeAbove: 0.5,
		clampTime:  0.01,
		relaxTime:  0.01);
	
	//output
	//output * 0.5;
	Out.ar(0, output *2);
}

//:
s.record("~/Desktop/test.wav")
~test = Buffer.read(s, "/Users/jsk/Desktop/test.wav")
~test.plot


//:
/*
tests performed:

High threshold (0.00044) & gain sound card (1/4) =======> 
1. better performance than fft, table hit is not detected. One has to hit the table quite hard for it to be detected. 
2. performance for very low signals is not very good, some signals with fast transient are detected very nicely (exp. mallet stick (upwards)) others are not.
3. performance for scratching is not good at all, most of the scratching is not detected. One has to scratch very intensivly for it to respond

Low threshold: (7.19401e-06) & gain sound card(1/4) ========>
1. very low signals are not detected (pp pianissimo and more quiet => (ppp))
2. better performance compared to FFT reqarding other sounds such as table impact, altough loud claps are detected. Still beter than FFT regarding claps.
3. scratching is detected as multiple impacts, good performance
*/