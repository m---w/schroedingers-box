// =====================================================================
// SuperCollider Workspace
// =====================================================================

//https://doc.sccode.org/Classes/Onsets.html
//: FFT detection
~odi = {
    var sig, chain, onsets, pips;
	
    // Input signal
    //sig = SoundIn.ar(0, 1.0)!2;
	//sig = PlayBuf.ar(2, ~sample, loop:1);
	sig = PlayBuf.ar(1, ~sample, BufRateScale.kr(~sample), loop: 0);
    chain = FFT(LocalBuf(512), sig);
	
	//MouseX is actually the threshold
    onsets = Onsets.kr(chain, MouseX.kr(0,1), \rcomplex);
	
    // output sound
    pips = SinOsc.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.001, 0.2), onsets)) * 5;


	Out.ar(0, Pan2.ar(pips));
	Out.ar(1, Pan2.ar(sig));
	
}.play;
//:
~odi.free; // Free the synth
//:


//: Detection via the Amplitude class,
// there has to be a threshold, where if the sig has reached smth is triggered
// it also has to .set the amplitude value during hiting (if goes higher it sets the amp value to the according level)

//: =====================================================================
//Simplest onset detector
play{
	| cutoff = 4000, rt = 0.1 |
	var out, thres;
	var sig = SoundIn.ar();
	sig = HPF.ar(sig, cutoff);
	sig = sig.squared;
	sig = Amplitude.ar(sig, attackTime:0.0, releaseTime:rt);
	//sig = DetectSilence.ar(sig, MouseX.kr(0.0, 1.0), 0.0);

	//sig = sig.isStrictlyPositive;
	//cannot be applied to a ugen
	//sig.scope;

	thres = MouseX.kr(0.0);
	sig = Schmidt.ar(sig, thres, thres);
	thres.poll;
	sig.poll;
	//postln{thres, "Schmidt_trig:" sig.poll};
	out = EnvGen.kr(Env.perc(0.0, 0.001), sig, doneAction:0) * SinOsc.ar(2222);
	out;
}
//:








//:
s.scope;
s.meter;

//Amplitude tracking onset detection
//:=======================================================================
fork{
| flagtime = 0.0075, slagtime = 0.2, fastmul = 0.9 |
	var sig, flsig, slsig, out;
	//s.record("~/Desktop/HWR2.wav");
	1.wait;
play{
	//====SOUNDIN====
	//sig = SoundIn.ar();

	//====BUFFER=====
	//sig = PlayBuf.ar(2, ~sample, loop:1);
	
	sig = Env.perc(0.000, 0.05, curve:'sin').kr(doneAction:0) * PinkNoise.ar(1);

	~siginit = sig;






	///////////////////////////
	//CAREFULL HERE! SUPER - AMPLIFIED!!!
	sig = HPF.ar(sig, 4000, 10);
	//:=======================
	//////////////////////////





	
	sig = sig.squared;
	//out = sig;
	//sig = sig.abs;

	//-60.dbamp = 0.001
	out = Amplitude.ar(sig, 0.001, -60.dbamp);
	



	//for testing
	//flagtime = MouseX.kr(0.0, 0.1).poll;
	

	//convienient value
	flagtime = 0.0075;

	
	//SMOOTHING & TREND SUBTRACTION
	//flag-time ==>> 0.0076
	flsig = Lag.ar(out, flagtime);
	slsig = Lag.ar(out, slagtime);
	out = fastmul * flsig - slsig;

	//half wave rectification
	out = out.max(0);
	out = (1 * out) - 0.05;
	//out = out.max(0);
	
	
	//out.scope;

	//threshold detection
	//InRange.ar()
	//OR
	//around 0.34 works ok
	//threshold detection with hysterisis
	//out = Schmidt.ar(out, MouseX.kr(0.0, 1.0), MouseX.kr(0.0, 1.0).poll);
	out.poll;
	out = SinOsc.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.4, 0.2), gate:out));
	//out = EnvGen.kr(Env.perc(0.0, 0.001), gate:out, doneAction:0) * SinOsc.ar(2222);
	


	Out.ar(0, Pan2.ar(~siginit, -0.99));
	Out.ar(0, Pan2.ar(out, 0.99));
	//Out.ar([0,1], Pan2.ar(out * 10, 1));
	//Out.ar([0,1], Pan2.ar(~siginit, -1));
	
};
};
//:


//:==============================================================================
//:
s.scope;

~b6 = Buffer.read(s,"/Users/jsk/Desktop/HWR2.wav");
~b6.plot;

~sample = Buffer.read(s,"/Users/jsk/Desktop/sample.wav", 40000, -1900);

~sample.plot;

//:
//FIrst sig
76804, 
85603

//final thing
77066,
78197
//:
play{EnvGen.kr(Env.perc(0.0, 0.01, curve: \sine), doneAction:0) * LPF.ar(PinkNoise.ar(), 7000);}
//:

{Env.perc(0.001, 0.02, curve:'sin').kr(doneAction:0)}.plot
//:

~b1 = Buffer.read(s, "/Users/jsk/Desktop/recs_sB/initial_sig.wav");
~b2 = Buffer.read(s, "/Users/jsk/Desktop/recs_sB/env_track.wav");
~b3 = Buffer.read(s, "/Users/jsk/Desktop/recs_sB/smoothing_subtraction.wav");
~b4 = Buffer.read(s, "/Users/jsk/Desktop/recs_sB/testersmooth.wav");

~b5 = Buffer.read(s, "/Users/jsk/Desktop/first.wav");

~b6 = Buffer.read(s,"/Users/jsk/Desktop/HWR2.wav");
//:
~b1.plot;
~b2.plot;
~b3.plot;
~b4.plot;

//:




//:
//s.record("~/Desktop/schroedingers_box/onset_detection/impact.wav")
//play{SoundIn.ar(0, 1)}
//:

















//tests
b = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/onset_detection/impact.wav"); 
play{PlayBuf.ar(2,b)}
//:
plot{[Lag.ar(Pulse.ar, 0.001), Pulse.ar]};
//plot{Pulse.ar}
//:

plot{[Lag.ar(SinOsc.ar().squared, 0.01), Lag.ar(SinOsc.ar().squared, 0.2)]}

{[Impulse.ar(2).squared, Lag.ar(Impulse.ar(2).squared, 0.01)]}.plot(0.001)


plot{[ Lag.ar(SinOsc.ar().abs, 0.01) - Lag.ar(SinOsc.ar().abs, 0.2)]}
plot{[ Lag.ar(SinOsc.ar().squared, 0.01) - Lag.ar(SinOsc.ar().squared, 0.2)]}


//:
