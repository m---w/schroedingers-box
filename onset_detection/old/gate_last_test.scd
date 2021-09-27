//=========================
//THis is connected with the gate closing thing so I can reduce active synths in the server == less CPU 

//: simple example that it works... doesnt work in the oscdef for some reasong
SynthDef("sample_player",{
	| gate = 1, amp = 0.1, bufnum = 1 |
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:1, bufnum: bufnum, rate: 0.1, trigger: gate);
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 0.0), gate: gate, doneAction:2) * amp;
	//no sound must exceed 1.5 sec
	//sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
	Out.ar(0, sig)
}).add;

//:+
~sp.set(\gate, 0);
~sp = Synth(\sample_player, [\bufnum, f.value(~sound), \rate, 0.1, \amp, 0.2, \gate,1]);
//:+
//:
/*
Schroedinger's Box
SuperCollider Patch for Bela
2021 Jason Svoronos-Kanavas, Marian Weger 
*/

s = Server.default;

// Set up options for the Bela
//s.options.numAnalogInChannels = 4;
//s.options.numAnalogOutChannels = 4;
//s.options.numDigitalChannels = 0;
s.options.maxLogins = 4;

s.options.blockSize = 64;
s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 8;

s.waitForBoot{

	~sound1var1 = Buffer.readChannel(s, "/Users/jsk/Desktop/schroedingers_box/sounds/sound3_vars/metaliko_kouti_diafores _attakes_var1.wav", channels:1);
	~sound1var2 = Buffer.readChannel(s, "/Users/jsk/Desktop/schroedingers_box/sounds/sound3_vars/metaliko_kouti_diafores _attakes_var2.wav", channels:1);
	~sound1var3 = Buffer.readChannel(s, "/Users/jsk/Desktop/schroedingers_box/sounds/sound3_vars/metaliko_kouti_diafores _attakes_var3.wav", channels:1);

	//~sound1var1 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var01.wav", channels:1);
	//~sound1var2 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var2.wav", channels:1);
	//~sound1var3 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var3.wav", channels:1);
	//~sound1var4 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var04.wav", channels:1);
	//~sound1var5 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var05.wav", channels:1);
	
	~sound = [~sound1var1, ~sound1var2, ~sound1var3];//, ~sound1var4, ~sound1var5];

	f = { | in = 0 |
		var temp, arr, val, suf;
		arr = in;
		suf = Pn(Pshuf(in, 1), inf).asStream;
		temp = suf.next;
		if(temp == ~last){
			arr = in; 
			val = arr.remove(temp);
			arr.postln;
			temp = arr.choose;
			arr = arr.add(val);
		};
		~last = temp;
		temp;
	};
	
SynthDef("sample_player",{
	| gate, amp = 0.1, bufnum = 1 |
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:1, bufnum: bufnum, trigger: gate);
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 0.0), gate:gate, doneAction:2) * amp;
	//no sound must exceed 1.5 sec
	//sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
	Out.ar(0, sig)
}).add;

SynthDef(\tba_fba, {	
	var sig, sighpf, sigsquared, lpf1, lpf2, derivative, ttrig, tthres, tsub, tsend, vel, temp;
	var chain, onsets, pips, ftrig, fthres;
	sig = SoundIn.ar(0);
	//===TBA===
	sighpf = HPF.ar(sig, 4000);
	sigsquared = sighpf.squared;
	lpf1 = LPF.ar(sigsquared, 25);
	derivative = Slope.ar(lpf1);
	lpf2 = LPF.ar(derivative, 100);
	tsub = 0.01 * lpf1 - lpf2;
	tsub = tsub.max(0);
	//2.04264e-06 a good value for low signal detection
	tthres = 1e-3;//MouseX.kr(0.0, 1e-3);
	//thres = 1000;
	ttrig = Schmidt.ar(tsub, tthres, tthres);
	tsend = SendTrig.kr(A2K.kr(ttrig), 0);
	//===FBA===
	chain = FFT(LocalBuf(256), sig);
	fthres = 0.5;//MouseX.kr(0.05,1);
	onsets = Onsets.kr(chain, fthres, \power, mingap:30);
	//vel track test
	vel = RunningMax.ar(sig, [onsets, ttrig]);
	ftrig = SendTrig.kr(onsets, 1, value:vel);
}).add;

//Vel track tests
a = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval, sp, vel, bufnum;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	vel = 0;
	vel = msg[3];
	
	fork{
		bufnum = f.value(~sound);

		/////////////CAREFUL HERE======================================
		p.set(\gate, 0); //THIS DOES NOT CLOSES THE GATE FOR SOME REASON
		p = Synth(\sample_player, [\bufnum, bufnum, \amp, vel, \gate, 1]);
		0.006.wait;
		msg[2].postln;
		fb_trigval = 0;
		if(msg[2] == 1){
			fb_trigval = 1;
			"FBA_agrees".postln;
		};
		if(fb_trigval == 0){p.set(\gate,0); "FBA_disagrees".postln;};
	};
},'/tr', s.addr);

Synth(\tba_fba);
};



ServerQuit.add({ 0.exit }); // quit if the button is pressed


//:
	
SynthDef("sample_player",{
	| gate = 1, amp = 0.1, bufnum = 1 |
	var sig, env, out;
	sig = PlayBuf.ar(numChannels:1, bufnum: bufnum, rate: 0.1, trigger: gate);
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 0.666, 0.0), gate: gate, doneAction:2) * amp;
	//no sound must exceed 1.5 sec
	//sig = sig * amp * Env.perc(attackTime:0.0,releaseTime:1).kr(doneAction:2);
	Out.ar(0, sig)
}).add;

//:+
~sp.set(\gate, 0);
~sp = Synth(\sample_player, [\bufnum, f.value(~sound), \rate, 0.1, \amp, 0.2]);

//:+