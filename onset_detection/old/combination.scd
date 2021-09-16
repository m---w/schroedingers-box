// ======================================================================================
// Combination of both FBA and TBA
// ======================================================================================

//:
~sample = Buffer.readChannel(s,"/Users/jsk/Desktop/schroedingers_box/Mallet_impacts/hardest.wav", 90000, -48900, channels:[0]);

//:
//Implementation: HARD REAL-TIME ONSET DETECTION OF PERCUSSIVE SOUNDS ==> Luca Turchet

play{
	var sig, initsig, sigsquared, env, envtrue, lpf1, lpf2, derivative, trig, output, thres, impact_amp, tsub, tsend;
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
	//[lpf2, tsub].poll;
	
	//thres = MouseX.kr(0.0, 1e-8);
	//2.04264e-06 a good value for low signal detection
	thres = MouseX.kr(0.0, 1e-3);
	thres = 1000;
	//thres.poll;
	trig = Schmidt.ar(tsub, thres, thres);
	//trig.poll;

	//send osc msg trigger
	tsend = SendTrig.kr(A2K.kr(trig), 0, value:1);
	
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
	
	output = WhiteNoise.ar(0.5) * Env.perc(0.000, 0.05).kr(gate: trig);
	/*PlayBufCF.ar(
		2,
		~sound,
		trigger: trig,
		doneAction:0, n:4) * Amplitude.ar(lpf2, 0.01, 4) * 2;*/
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
	//Out.ar(0, output *2);
}

//: