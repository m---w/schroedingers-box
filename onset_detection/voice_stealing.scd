//:
SynthDef(\sample_player,{
	| gate = 0, amp = 0.1, bufnum = 1, f = 1, releaseTime = 0.0|
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:2, bufnum: bufnum, rate: f, trigger: gate);
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, releaseTime), gate: gate, doneAction:2) * amp;
	//no sound must exceed 1.5 sec
	//sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
	Out.ar(0, sig)
}).load(s);

//:+
~sp.set(\gate, 0);
~sp = Synth(\sample_player, [\bufnum, f.value(~sound), \rate, 0.1, \amp, 0.2, \gate,1]);
//:

// If you supply an Instr as an argument, it must be followed by an argument array or nil.

// The Voicer makes a Patch for the inner Instr using the arg array immediately following.



//:
v = Voicer.new(5, "sample_player");//, [\bufnum, ~sound.choose, \amp, 1.0.rand]);  
//:
fork{
	10.do{
		//v.gate(f, 10, 1, [\amp, 0.1, \bufnum, ~sound.choose]);
		//v.release(4);
		v.trigger(0, 1, [\amp, 0.1, \gate, 1, \bufnum, ~sound.choose]);  
		0.2.wait;
	}
	
}

//:

// ===onset detection===
SynthDef(\tba_fba, {	
	var sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend, vel, temp;
	var chain, onsets, pips, ftrig, fthres;
	sig = SoundIn.ar([0]);
	//===TBA===
	sighpf = HPF.ar(sig, 4000);
	sigsquared = sighpf.squared;
	lpf1 = LPF.ar(sigsquared, 25);
	derivative = Slope.ar(lpf1);
	lpf2 = LPF.ar(derivative, 100);
	tsub = 0.01 * lpf1 - lpf2;
	tsub = tsub.max(0);
	//2.04264e-06 a good value for low signal detection
	tthres = MouseX.kr(0.0, 1e-3);
	//thres = 1000;
	ttrig = Schmidt.ar(tsub, tthres, tthres);
	tsend = SendTrig.kr(A2K.kr(ttrig), 0);
	//===FBA===
	chain = FFT(LocalBuf(256), sig);
	fthres = MouseX.kr(0.05,1);
	onsets = Onsets.kr(chain, fthres, \rcomplex);
	//vel track test
	vel = RunningMax.ar(sig, [onsets, ttrig]);
	ftrig = SendTrig.kr(onsets, 1, value:vel);
}).play;

// ===onset detection combination===
a = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval, sp, vel;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	vel = 0;
	vel = msg[3];
	fork{
		v.release;
		//v.trigger(2, 1, [\bufnum, f.value(~sound, ~sound.size), \amp, vel]);
		//v.gate(1, 0.1, 1, [\amp, vel * 0.5, \bufnum, ~sound.choose]);
		v.trigger(1, 1, [\amp, vel, \gate, 1, \bufnum, f.value(~sound)]);  
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



























//: VOICER E.G.
//:+

//:
Quarks.gui
//:

(

SynthDef.new("harpsi", {

	arg outbus = 0, freq = 440, gate = 0;

	var out;

	out = EnvGen.ar(Env.adsr, gate, doneAction:2) *

		Pulse.ar(freq, 0.25, 0.75);

	Out.ar(outbus, [out, out]);

}).load(s);

)

//:

// or



(

Instr.new([\harpsi], {

	arg freq = 440, gate = 0;

	var out;

	out = EnvGen.ar(Env.adsr, gate, doneAction:2) *

		Pulse.ar(freq, 0.25, 0.75);

	[out, out]

});

)
//:


Tip: If you want the instrument to be velocity-sensitive, Latch the gate argument to get the velocity:


//:
SynthDef.new("harpsi", {

	arg outbus = 0, freq = 440, gate = 0;

	var out, amp;

	amp = Latch.kr(gate, gate) * 0.5 + 0.5;

	out = EnvGen.ar(Env.adsr, gate, doneAction:2) *

		Pulse.ar(freq, 0.25, amp);

	Out.ar(outbus, [out, out]);

}).load(s);

//:



// with synthdef (depends on synths defined above):

v = Voicer.new(8, "harpsi");  // 8 voices, all harpsi



// with Instr & MixerChannel:

s = Server.local; s.boot;

m = MixerChannel.new("harpsi", s, 2, 2);

v = Voicer.new(8, Instr.at([\harpsi]), target:m);


//:
// a nested Instr:

(

i = Instr([\harpsi], {

	arg freq = 440, gate = 0;

	var out;

	out = EnvGen.ar(Env.adsr, gate, doneAction:2) *

		Pulse.ar(freq, 0.25, 0.25);

	[out,out]

});

f = Instr([\test, \rlpf], {

	arg audio, ffreq = 500, rq = 0.1;

	RLPF.ar(audio, ffreq, rq);

});

)
//:


// If you supply an Instr as an argument, it must be followed by an argument array or nil.

// The Voicer makes a Patch for the inner Instr using the arg array immediately following.

v = Voicer(8, Instr.at([\test, \rlpf]), [\audio, Instr.at([\harpsi]), nil, \ffreq, 5000, \rq, 0.08]);

v = Voicer.new(2, "harpsi");  // uses Server.local

f = Array.fill(10, { 1000.0.rand + 50 });

v.trigger(f);  // play 5 notes

v.release(f);  // release the same

v.gui