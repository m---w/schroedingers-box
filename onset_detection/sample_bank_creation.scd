SynthDef(\boing, {
	| freq = 666, amp = 0.5, gate |
	var sig, env, out;
	sig = SinOsc.ar(XLine.kr(freq, freq/10, 1)) * LFPulse.kr(7, 0.1);
	env = Env.perc(1, 1).kr(gate: gate, doneAction:2);
	out = sig * env;
	Out.ar(0, Pan2.ar(out, SinOsc.kr(1.6)));
}).add;