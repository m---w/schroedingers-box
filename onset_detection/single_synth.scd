SynthDef(\tba_fba, {
	
	var sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend, vel, temp;
	var chain, onsets, pips, ftrig, fthres;

	sig = SoundIn.ar();
	
	//===TBA===
	sighpf = HPF.ar(sig, 4000);
	sigsquared = sighpf.squared;
	lpf1 = LPF.ar(sigsquared, 25);
	derivative = Slope.ar(lpf1);
	lpf2 = LPF.ar(derivative, 100);
	tsub = 0.01 * lpf1 - lpf2;
	tsub = tsub.max(0);
	//2.04264e-06 a good value for low signal detection
	tthres = MouseX.kr(0.0, 1e-3);
	//thres = 1000;
	ttrig = Schmidt.ar(tsub, tthres, tthres);
	tsend = SendTrig.kr(A2K.kr(ttrig), 0);
	
	//===FBA===
	chain = FFT(LocalBuf(256), sig);
	fthres = MouseX.kr(0.05,1);
	onsets = Onsets.kr(chain, fthres, \rcomplex);
	
	
	//vel track test
	vel = RunningMax.ar(sig, [onsets, ttrig]);
	
	ftrig = SendTrig.kr(onsets, 1, value:vel);
	
	
}).add;
//:
Synth(\tba_fba);
//:
//Vel track tests
a = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval, sp, vel;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	vel = 0;

	vel = msg[3];
	fork{
		sp = Synth(\sample_player, [\amp, vel]);
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


~sound = Buffer.read(s,"/Users/jsk/Desktop/schroedingers_box/sounds/sound2_vars/kagelo01.wav");

SynthDef("sample_player",{
	| gate = 1, amp = 0.1|
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:2, bufnum:~sound, trigger: gate);
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 1.0), gate: gate, doneAction:2);
	//no sound must exceed 9 sec
	sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
	Out.ar(0, Pan2.ar(sig))
}).add;



//:
