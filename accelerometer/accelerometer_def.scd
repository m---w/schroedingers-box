/*
	Schroedinger's Box
	SuperCollider Patch for Bela
	2021 Jason Svoronos-Kanavas, Marian Weger 
*/

//Accelerometer

//leaves
~leaves1 = Buffer.readChannel(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/leaves-in-movement_short48.wav", channels:1);

~accsound = [~leaves1];

//metal ball
~ball1 = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/rolling-wood-ball1_48.wav");
~ball2 = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/rolling-wood-ball2_48.wav");
~ball3 = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/rolling-wood-ball3_48.wav");
~ball4 = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/rolling-wood-ball4_48.wav");
~accsound = [~ball1, ~ball2, ~ball3, ~ball4];

//:
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

SynthDef(\acc, {
	| bufnum, rate = 1, pos = 0, trig = -1, amp = 0.0, cutoff = 5000, p = 0.05 |
	var sig;
	sig = PlayBuf.ar(1, bufnum, rate:rate, trigger:trig, startPos:pos, loop:0);
	sig = LPF.ar(sig, cutoff);
	sig = sig - DelayL.ar(sig, maxdelaytime: 0.01, delaytime: (p*0.01)+(0.5/48000));
	sig = sig * amp * 2;
	Out.ar(0, sig!2)
}).add;
//:

t = Synth(\acc, [\amp, 0.0, \bunfum, ~accsound.choose]);
//initialisation
~trigcounter = 0; //do not change buffer super fast
~rolled = 1; //if ball rolled
~bufferinit = 0;

OSCdef(\acc, {
	| msg, time, addr, port |
	var x, y, z, sig, cutoff, ampval;
	
	x = msg[1].linlin(-10, 10, -1.0, 1.0);
	y = msg[2].linlin(-10, 10, -1.0, 1.0);

	if(~bufferinit == 0){t.set(\bufnum, f.value(~accsound))};
	
	if((x.abs < 0.1) && (~trigcounter == 0)){

		if((x.abs.round(0.01) == 0.0) && (~rolled == 1)){
			t.set(\amp, 0.03);
			if(~trigcounter == 0){
				t.set(\bufnum, f.value(~accsound));
				~trigcounter = ~trigcounter + 1;

			};
			~rolled = 0;
			"eieiei".postln;};
		
		ampval = x.abs.linlin(0.0, 1.0, 0.0, 0.3);
		t.set(\amp, ampval.lag(0.1));	
		t.set(\trig, -1);
		t.set(\p, 0.1.linrand);
		
	};
	
	if((x.abs > 0.1) && (x.abs < 0.8) && (~trigcounter == 0)){
		t.set(\amp, x.abs.linlin(0.0, 1.0, 0.0, 0.3), \trig, 1, \pos, rrand(0.0, 0.3));
		cutoff = (14000 * x.squared) + rrand(4000, 6000);
		t.set(\cutoff, cutoff);
		~rolled = 1;
		
	};

	if(x.abs > 0.2){~trigcounter = 0};
	
	if((x.abs > 0.8) && (x.abs < 0.99)){
		t.set(\amp, x.abs.log.abs * 2, \rate, 1 + (x.abs/4));
		
	};

	//for the first sample playback, runs only once
	~bufferinit = 1;

}, '/accxyz'

);
//:

