//for_recording
fork{
	s.record("/Users/jsk/Desktop/sound1.wav");
	0.02.wait;
	Synth("boing", [\gate, 1]);
}
//: buffer_read
~sound = Buffer.read(s, "/Users/jsk/Desktop/sound1.wav")
~sound = Buffer.read(s, "/Users/jsk/Desktop/sound1.wav")
~sound.plot
//: playback

play{PlayBuf.ar(2, ~sound)}

//: sounds

//1
SynthDef(\boing, {
	| freq = 966, amp = 0.5, gate |
	var sig, env, out;
	sig = SinOsc.ar(XLine.kr(freq, freq/10, 1)) * SinOsc.kr(7);
	env = Env.perc(1, 1).kr(gate: gate, doneAction:2);
	out = sig * env;
	Out.ar(0, Pan2.ar(out, SinOsc.kr(1.5)));
}).add;

//2

