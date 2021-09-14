//https://doc.sccode.org/Classes/Onsets.html
//: FFT detection tuning
play{
    var sig, chain, onsets, pips;
	
    // Input signal
    sig = SoundIn.ar(0, 1.0);
    chain = FFT(LocalBuf(256), sig);
	
	//MouseX is actually the threshold
    onsets = Onsets.kr(chain, MouseX.kr(0,1).poll, \rcomplex);
	
    // output sound
    //pips = SinOsc.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets)) * 5;

	//sample
	
	pips =
	PlayBufCF.ar(
		2,
		~sound,
		trigger: onsets,
		doneAction:0, n:4) * Amplitude.ar(sig, 0.01, 4) * 2;

	Out.ar(0, Pan2.ar(pips));
	//Out.ar(1, Pan2.ar(sig));
	
}
//:

/*
tests performed:

High threshold (0.6) & gain sound card (1/4) =======> 
1. table hit is not detected. One has to hit the table quite hard for it to be detected.
2. very low signals are still detected despite the high threshold.
3. scratching is detected as multiple impacts but a lower threshold is needed for them to be detected for sure.
4. loud claps are detected

Low threshold: (0.1) & gain sound card(1/4) ========>
1. table hits are detected. Even the small ones.
2. reacts good to the scratching
3. loud claps are detected more than before
*/