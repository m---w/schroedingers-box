// =====================================================================
// SuperCollider Workspace
// =====================================================================

//https://doc.sccode.org/Classes/Onsets.html
//: FFT detection
~odi = {
    var sig, chain, onsets, pips;
	
    // Input signal
    sig = SoundIn.ar(0, 1.0)!2;

    chain = FFT(LocalBuf(512), sig);
	
	//MouseX is actually the threshold
    onsets = Onsets.kr(chain, MouseX.kr(0,1), \rcomplex);
	
    // output sound
    pips = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.001, 0.2), onsets));
    Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(pips, 0.75, 1)
}.play;
//:
~odi.free; // Free the synth
//:







//: Detection via the Amplitude class,
// there has to be a threshold, where if the sig has reached smth is triggered
// it also has to .set the amplitude value during hiting (if goes higher it sets the amp value to the according level)
//:
//simple Schmidt paradigm
scope{ Schmidt.kr(
	//Amplitude.ar(
	SoundIn.ar.abs, MouseY.kr(0.0, 1.0).poll, 1.0)}; // see the trigger

//:


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
	out = EnvGen.kr(Env.perc(0.0, 0.01), sig, doneAction:0) * SinOsc.ar(1666);
	out;
}
//:


//:+
| flagtime = 0.01, slagtime = 0.2, fastmul = 0.6 |
var sig, flsig, slsig, out;
play{
	sig = SoundIn.ar(0, 1);
	//	sig = HPF.ar(sig, 4000);
	sig = sig.squared;
	//sig = sig.abs;

	//0.2 IS A CONVIENIENT VALUE--> impacts are detected, && smoothed
	out = Amplitude.ar(sig, 0.0, MouseY.kr(0.0, 0.2).poll);
	//out.scope;
	
	//SMOOTHING & TREND SUBTRACTION
	flsig = Lag.ar(out, flagtime);
	slsig = Lag.ar(out, slagtime, fastmul);
	out = fastmul * flsig - slsig;
	out.scope;
	
	//around 0.34 works ok
	//threshold detection with hysterisis
	out = Schmidt.ar(out, MouseX.kr(0.0, 0.5), MouseX.kr(0.0, 1.0).poll);
	out.poll;
	out = EnvGen.kr(Env.perc(0.0, 0.01), out, doneAction:0) * SinOsc.ar(666);
};
//:+

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