//https://doc.sccode.org/Classes/Onsets.html
//: FFT detection tuning
play{
    var sig, chain, onsets, pips, trig;
	
    // Input signal
    sig = SoundIn.ar(0, 1.0);
    chain = FFT(LocalBuf(256), sig);
	
	//MouseX is actually the threshold
    onsets = Onsets.kr(chain, MouseX.kr(0,1).poll, \rcomplex);
	
    // output sound
    //pips = SinOsc.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets)) * 5;

	//Trigger
	trig = SendTrig.kr(onsets, 0);


	//sample
	pips = WhiteNoise.ar(0.5) * Env.perc(0.000, 0.05).ar(gate: onsets) * Amplitude.ar(sig, 0.01, 4) * 2; 
	/*PlayBufCF.ar(
		2,
		~sound,
		trigger: onsets,
		doneAction:0, n:4) * Amplitude.ar(sig, 0.01, 4) * 2;*/

	Out.ar(0, Pan2.ar(pips));
	//Out.ar(1, Pan2.ar(sig));
	
}
//:
~sound = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/onset_detection/sound1.wav");
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

// register to receive this message
o = OSCFunc({ arg msg, time;
    [time, msg].postln;

	//send trig ==from which algorithm== detection
	if(msg[2] == 0){"FBA".postln};
	if(msg[2] == 1){"TBA".postln};
	//~synth.set(\gate, msg[3]);
},'/tr', s.addr);

//:

SynthDef("sample_player",{
	| gate |
	var sig, env, out;
	sig = PlayBufCF.ar(
		2,
		~sound,
		trigger: gate,
		doneAction:0, n:4) * Amplitude.ar(sig, 0.01, 4) * 2;
	Out.ar(0, Pan2.ar(sig))
}).add


