SynthDef(\tba_fba, {
	
	var sig, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend;
	var chain, onsets, pips, ftrig, fthres;

	sig = SoundIn.ar();

	//===TBA===
	sig = HPF.ar(sig, 4000);
	sigsquared = sig.squared;
	lpf1 = LPF.ar(sigsquared, 25);
	derivative = Slope.ar(lpf1);
	lpf2 = LPF.ar(derivative, 100);
	tsub = 0.01 * lpf1 - lpf2;
	tsub = tsub.max(0);
	//2.04264e-06 a good value for low signal detection
	tthres = MouseX.kr(0.0, 1e-3);
	//thres = 1000;
	ttrig = Schmidt.ar(tsub, tthres, tthres);
	tsend = SendTrig.kr(A2K.kr(ttrig), 0, value:1);

	//===FBA===
	chain = FFT(LocalBuf(256), sig);
	fthres = MouseX.kr(0.5,1);
	onsets = Onsets.kr(chain, fthres, \rcomplex);
	ftrig = SendTrig.kr(onsets, 1, value:1);

	
}).add;
//:
Synth(\tba_fba);


a = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval, sp;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	
	fork{
		sp = Synth(\sample_player);
		0.006.wait;
		msg[2].postln;
		fb_trigval = 0;
		if(msg[2] == 1){
			fb_trigval = 1;
			"FBA_agrees".postln;
		};
		if(fb_trigval == 0){sp.set(\gate,0); "FBA_disagrees".postln;}
		
	};
},'/tr', s.addr);
//:
~sound = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/onset_detection/sound1.wav");

SynthDef("sample_player",{
	| gate = 1|
	var sig, env, out;
	sig = PlayBufCF.ar(
		2,
		~sound,
		trigger: gate, n:4);// * Amplitude.ar(sig, 0.01, 4) * 2;
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 1, 0.0), gate: gate) * 0.5;
	Out.ar(0, Pan2.ar(sig))
}).add
//:


