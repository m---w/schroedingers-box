~sound1var1 = Buffer.read(s, "/Users/jsk/Desktop/sounds_processed/ionio/sound1_vars/atakes_vasi_ixeion_me_kleidi_var01.wav");
~sound1var2 = Buffer.read(s, "/Users/jsk/Desktop/sounds_processed/ionio/sound1_vars/atakes_vasi_ixeion_me_kleidi_var02.wav");
~sound1var3 = Buffer.read(s, "/Users/jsk/Desktop/sounds_processed/ionio/sound1_vars/atakes_vasi_ixeion_me_kleidi_var03.wav");
~sound1var4 = Buffer.read(s, "/Users/jsk/Desktop/sounds_processed/ionio/sound1_vars/atakes_vasi_ixeion_me_kleidi_var04.wav");
~sound1var5 = Buffer.read(s, "/Users/jsk/Desktop/sounds_processed/ionio/sound1_vars/atakes_vasi_ixeion_me_kleidi_var05.wav");

~sound = [~sound1var1, ~sound1var2, ~sound1var3, ~sound1var4, ~sound1var5];
~sound.size;

//: Works but there are duplicates
f = { | b = 0, l = 0 | b.scramble.keep(l); b.choose};
f.value(~sound, ~sound.size);


//: sample player configured for sample picking
SynthDef(\sample_player,{
	| gate = 1, amp = 0.9, bufnum = 0 |
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:2, bufnum:bufnum, rate:LFNoise1.kr(0.1).range(0.98, 1.02), trigger: gate);
	sig = LPF.ar(sig, LFNoise1.kr(0.1).range(6666, 20000));
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 1.0), gate: gate);
	//no sound must exceed 9 sec
	sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:9).kr(doneAction:2);
	Out.ar(0, Pan2.ar(sig))
}).add;
//:
a = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval, sp, vel;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	vel = 0;

	vel = msg[3];
	fork{
		sp = Synth(\sample_player, [\amp, vel, \bufnum, f.value(~sound, ~sound.size)]);
		0.006.wait;
		msg[2].postln;
		fb_trigval = 0;
		if(msg[2] == 1){
			fb_trigval = 1;
			"FBA_agrees".postln;
		};
		if(fb_trigval == 0){sp.set(\gate,0); "FBA_disagrees".postln;}
		
	};
},'/tr', s.addr);
//:
m = OSCFunc({ | msg, time |
	[time, msg].postln;
	msg[1].postln;
	//sound1
	if(msg[1] == 0){~sound = [~sound1var1, ~sound1var2, ~sound1var3, ~sound1var4, ~sound1var5]};
	//sound2
	if(msg[1] == 1){~sound = [Buffer.read(s,"/Users/jsk/Desktop/schroedingers_box/onset_detection/sound2.wav") ]};
},'/soundpick');
//:
Synth("sample_player", [\bufnum, f.value(~sound, ~sound.size)])
//:

//OSC_msg sender
~n = NetAddr("192.168.184.21", 57120);
~n.sendMsg('/soundpick',  1);



//:this does it but doesnt work in the way I want to
(
{
    var a, freq, trig;
    a = Dxrand([1, 3, 2, 7, 8], inf);
    trig = Impulse.kr(MouseX.kr(1, 400, 1));
    freq = Demand.kr(trig, 0, a) * 30 + 340;
    SinOsc.ar(freq) * 0.1

}.play;
)

//:
f = { | b = 0 | b = b.scramble; b[~c].postln; ~c = ~c + 1; ~c.postln; if(~c == ~sound1.size){~c = 0};}
//:
//~c = 0;
f.value(~sound1, ~sound1.size)

//:
