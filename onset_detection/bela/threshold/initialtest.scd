// =====================================================================
// SuperCollider Workspace
// =====================================================================

~bus = Bus.audio(s, 1);

//:

x = {
	var sig = In.ar(~bus, 1);
	//sig.poll;
	Out.ar(0, sig);
	sig = Amplitude.ar(sig);
	sig.poll;
	
};
x.play
//:
SynthDef(\sine, {
	var sig, env;
	sig = SinOsc.ar(444 * SinOsc.ar(242));
	env = Env.perc.kr(doneAction:2);
	Out.ar(~bus, sig * env);
}).add;

Synth("sine");
//:

v = Voicer(1, \sine);


m = MixerChannel.new(\sine, s, 2, 2, /*inbus:~bus,*/outbus:~bus);
v = Voicer.new(8, \sine, target:m);
v.trigger(1)

//:
~bus = Bus.new(\audio, 4, 1)

~bus = Bus.audio(s, 1);
//:
fork{
	x = {
		var sig = In.ar(~bus, 1);
		//sig.poll;
		Out.ar(0, sig);
		sig = Amplitude.ar(sig);
		sig.poll;		
	};
	x.play;
	0.5.wait;
	//10.do{"firsttime".postln; 0.01.wait;};
	m = MixerChannel.new(\sine, s, 2, 2,inbus:~bus);
	v = Voicer.new(8, \sine, target:m);
	0.5.wait;
	10.do{"popos".postln};
	m = MixerChannel.new(\sine, s, 2, 2, outbus:~bus);
	v = Voicer.new(8, \sine, target:m);
	0.25;
	10.do{
		v.trigger(1);
		0.2.wait;
	};
}

Execution warning: Class 'MixerControl' not found
Execution warning: Class 'BusDict' not found