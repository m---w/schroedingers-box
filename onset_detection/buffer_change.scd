//: Works but there are duplicates
f = { | b = 0, l = 0 | b.scramble.keep(l); b.choose};
f.value(~sound, ~sound.size);


//: sample player configured for sample picking
SynthDef(\sample_player,{
	| gate = 1, amp = 0.9, bufnum = 0 |
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:2, bufnum:bufnum, rate:LFNoise1.kr(0.1).range(0.98, 1.02), trigger: gate);
	sig = Mix(sig);
	sig = LPF.ar(sig, LFNoise1.kr(0.1).range(6666, 20000));
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 1.0), gate: gate);
	//no sound must exceed 9 sec
	sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:9).kr(doneAction:2);
	Out.ar(0, Pan2.ar(sig))
}).add;
//:
//initialisation
//for the first sound
//~sound = [~sound1var1, ~sound1var2, ~sound1var3, ~sound1var4, ~sound1var5]
//button count
~button = 0;
m = OSCdef(\next_sound, { | msg, time, button = 0 |
	[time, msg].postln;
	msg[1].postln;
	
	//counter_via_button_hits
	if(msg[1] == 1.0){
		~button = ~button + 1;
	};
	if(~button == 0){"press the button to start".postln};
	
	if(~button == 1){"press the button to start".postln};
	
	//sound1
	if(~button == 2){~sound = [~sound1var1, ~sound1var2, ~sound1var3, ~sound1var4, ~sound1var5]};
	
	//sound2
	if(~button == 3){~sound = [~sound2var1, ~sound2var2]};
	
	//sound3
	if(~button == 4){~sound = [~sound3var1, ~sound3var2, ~sound3var3]};

	//finish
	if(~button == 5){s.freeAll};
		
	
},'/soundpick/2');
//:
Synth("sample_player", [\bufnum, f.value(~sound, ~sound.size)]);
~button;
//:
//OSC_msg sender
~n = NetAddr("192.168.43.220", 57120);
~n.sendMsg('/soundpick/2',  1);


~sound.size
~sound[0].postln








//: When first tests are done ==> apply appropriate changes in the oscdef
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










//=================RANDOMISATION====================
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
b = [1, 2, 3];
f = { | b = 0 | var temp; temp = b.choose; b = b.scramble; b = b.choose; b. //if((b == temp) && (temp != b.last)){b = b + 1};b}; //if(){b = b -1}); }
	f.}value(b);

//:
f = { | b = 0 | b = b.scramble; b[~c].postln; ~c = ~c + 1; ~c.postln; if(~c == ~sound1.size){~c = 0};}
//:
//~c = 0;
f.value(~sound1, ~sound1.size)

//: