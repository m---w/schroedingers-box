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
    pips = WhiteNoise.ar(EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets));
    Pan2.ar(sig, -0.75, 0.2) + Pan2.ar(pips, 0.75, 1)
}.play;
//:
~odi.free; // Free the synth
//:



//: Detection via the Amplitude class,
// there has to be a threshold, where if the sig has reached smth is triggered
// it also has to .set the amplitude value during hiting (if goes higher it sets the amp value to the according level)

play{
	Amplitude.kr(
		Out.ar(0, SoundIn.ar())).plot}
Schmidt.ar()
//:


{ Schmidt.kr(
	//Amplitude.ar(
	SoundIn.ar.abs, MouseY.kr(0.0, 1.0).poll, 1.0)}.scope; // see the trigger

//:
//

//:+
var sig, abs, out;
scope{
	sig = SoundIn.ar(0, 2);
	abs = sig.abs;
	//out = abs;
	out = Amplitude.ar(abs, 0.01, 0.01);
	out = Schmidt.kr(out, MouseX.kr(0.0, 1.0), 1.0);
	out.poll;
	out = EnvGen.kr(Env.perc, out, doneAction:0) * SinOsc.ar(444);
};
//:+

//if(out == 1){
//play{Out.ar(0, SinOsc.ar(4444) * 0.2 * Env.perc.kr(doneAction:2))}
//}
//:+