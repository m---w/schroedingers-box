// =====================================================================
// SuperCollider Workspace
// =====================================================================

SynthDef.new("harpsi", {

	arg outbus = 0, freq = 440, gate = 0;

	var out, amp;

	amp = Latch.kr(gate, gate) * 0.5 + 0.5;

	out = EnvGen.ar(Env.adsr, gate, doneAction:2) *

		Pulse.ar(freq, 0.25, amp);

	Out.ar(outbus, [out, out]);

}).load(s);

x = Synth("harpsi", );

//:
x = Synth("harpsi", [\gate,1]).register
x.isPlaying
