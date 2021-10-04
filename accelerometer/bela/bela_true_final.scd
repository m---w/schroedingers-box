/*
	Schroedinger's Box
	SuperCollider Patch for Bela
	2021 Jason Svoronos-Kanavas, Marian Weger 
*/

//Accelerometer


/*
	Schroedinger's Box
	SuperCollider Patch for Bela
	2021 Jason Svoronos-Kanavas, Marian Weger 
*/

//Accelerometer

s = Server.default;

// Set up options for the Bela
s.options.numAnalogInChannels = 4;
s.options.numAnalogOutChannels = 4;
s.options.numDigitalChannels = 0;
s.options.maxLogins = 4;

s.options.blockSize = 64;
s.options.numInputBusChannels = 4;
s.options.numOutputBusChannels = 8;

s.waitForBoot{

~n = NetAddr("localhost", 57120);


	//extract accelerometer values and send them as osc msg
Ndef(\xaccvalues, {              
    |input=0|
    AnalogIn.kr(0);
});

Ndef(\yaccvalues, {              
    |input=0|
    AnalogIn.kr(1);
});

0.2.wait;
	
r = fork{
	inf.do {
		var x = Ndef(\xaccvalues).bus.getSynchronous;
		var y = Ndef(\yaccvalues).bus.getSynchronous;
		~n.sendMsg('/accxyz', x.postln, y.postln);
		(0.4).wait;
	}
};
	
0.2.wait;
	
r.play;




//leaves
~leaves1 = Buffer.readChannel(s, "./sounds_acc/leaves-in-movement_short1_48.wav", channels:1);
~leaves2 = Buffer.readChannel(s, "./sounds_acc/leaves-in-movement_short2_48.wav", channels:1);
~leaves3 = Buffer.readChannel(s, "./sounds_acc/leaves-in-movement_short3_48.wav", channels:1);
~leaves4 = Buffer.readChannel(s, "./sounds_acc/leaves-in-movement_short4_48.wav", channels:1);

~accsound = [~leaves1, ~leaves2,  ~leaves3,  ~leaves4];

//metal ball
~ball1 = Buffer.read(s, "./sounds_acc/rolling-wood-ball1_48.wav");
~ball2 = Buffer.read(s, "./sounds_acc/rolling-wood-ball2_48.wav");
~ball3 = Buffer.read(s, "./sounds_acc/rolling-wood-ball3_48.wav");
~ball4 = Buffer.read(s, "./sounds_acc/rolling-wood-ball4_48.wav");
~accsound = [~ball1, ~ball2, ~ball3, ~ball4];


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
	Out.ar(6, sig!2)
}).add;

0.5.wait;

t = Synth(\acc, [\amp, 0.0, \bunfum, ~accsound.choose]);
//initialisation
~trigcounter = 0; //do not change buffer super fast
~ytrigcounter = 0; 
~rolled = 1; //if ball rolled
~bufferinit = 0;

OSCdef(\acc, {
	| msg, time, addr, port |
	var x, y, z, sig, cutoff, ampval;
	
	x = msg[1].linlin(0.331, 0.48, -1.0, 1.0);
	y = msg[2].linlin(0.32, 0.48, -1.0, 1.0);

	[x, y].postln;

	if(~bufferinit == 0){t.set(\bufnum, f.value(~accsound))};
	
	if((x.abs < 0.1) && (~trigcounter == 0)){

		if((x.abs.round(0.01) == 0.0) && (~rolled == 1)){
			t.set(\amp, 0.03);
			if(~trigcounter == 0){
				t.set(\bufnum, f.value(~accsound));
				~trigcounter = ~trigcounter + 1;

			};
			~rolled = 0;
			"SAMPLE CHANGE".postln;};
		
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


	if(y.abs > 0.3){
		if((~ytrigcounter < 1) && (~rolled == 1)){
			play{
				Out.ar(6,
				PlayBuf.ar(
					numChannels:1,
					bufnum:f.value(~accsound),
					rate:1 + (y.abs/2),
					doneAction:2) * y.abs.linlin(0.0, 1.0, 0.0, 0.5) !2);
			};
			~ytrigcounter = ~ytrigcounter + 1;
			
			
		}
	};

	if(y.abs < 0.2){~ytrigcounter = 0};
	if(x.abs > 0.2){~trigcounter = 0};
	
	if((x.abs > 0.8) && (x.abs < 0.99)){
		t.set(\amp, x.abs.log.abs * 2, \rate, 1 + (x.abs/2));
		
	};

	//for the first sample playback, runs only once
	~bufferinit = 1;

}, '/accxyz'

);


};

ServerQuit.add({ 0.exit }); // quit if the button is pressed



