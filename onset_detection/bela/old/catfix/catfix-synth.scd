// =====================================================================
// SuperCollider Workspace
// =====================================================================

b = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/sounds/sound7_vars/cat_01.wav");

//:
SynthDef(\addsound, {
	| out = 0, bufnum, amp = 0.5, minwaittime = 0.5, maxwaittime = 1.5, cutoff = 500 |
	var sig, deltime;
	deltime = Rand(minwaittime, maxwaittime);
	sig = DelayN.ar(PlayBuf.ar(1, f.value(~soundcat_sum), doneAction:0)!2, deltime, deltime);
	sig = LPF.ar(sig, cutoff);
	sig = sig * Env.perc(deltime + 0.25, curve:8).kr(doneAction:2);
	Out.ar(out, sig);
}).add;

//:
