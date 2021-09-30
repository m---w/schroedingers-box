/*
	Schroedinger's Box
	SuperCollider Patch for Bela
	2021 Jason Svoronos-Kanavas, Marian Weger 
*/

//Accelerometer

~accsound = Buffer.readChannel(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/leaves-in-movement.wav", channels:1);
~accsound = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/rolling-wood-ball44100.wav");

~tick = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/ball_tick44100.wav");
~tick = Buffer.readChannel(s, "/Users/jsk/Desktop/schroedingers_box/accelerometer_sounds/hollow-tick.wav", channels:1);

//:
SynthDef(\acc, {
	| bufnum, rate = 1, pos = 0, trig = -1, amp = 0.5, cutoff = 5000 |
	var sig;
	sig = PlayBuf.ar(1, bufnum, rate:rate, trigger:trig, startPos:pos, loop:0);
	//sig = LPF.ar(sig, cutoff);
	sig = sig * amp * 2;
	Out.ar(0, sig!2)
}).add;

t = Synth(\acc);

OSCdef(\acc, {
	| msg, time, addr, port |
	var x, y, z, sig, cutoff, ampval;
	
	x = msg[1].linlin(-10, 10, -1.0, 1.0);
	y = msg[2].linlin(-10, 10, -1.0, 1.0);
	//[x,y].postln;
	if(x.abs < 0.1){
		ampval = x.abs.linlin(0.0, 0.1, 0.0, 0.3);
		ampval.postln;
		t.set(\amp, ampval);
		t.set(\trig, -1)};
	
	if((x < -0.2) || (x > 0.2)){
		t.set(\bufnum, ~accsound, \amp, 0.3, \trig, 1, \pos, rrand(0.0, 0.5));
		cutoff = (14000 * x.squared) + 6000;
		//cutoff.postln;
		t.set(\cutoff, cutoff);
	};
	if(x.abs > 0.9){
		t.set(\amp, x.abs.log.abs * 2);
		
	}

	

}, '/accxyz'

);
//:

