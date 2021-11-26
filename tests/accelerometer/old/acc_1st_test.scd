//bela acc 1st test

/*
	Schroedinger's Box
	SuperCollider Patch for Bela
	2021 Jason Svoronos-Kanavas, Marian Weger 
*/

//Accelerometer WORKX
//Send osc values to an OSC address (to localhost).

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

Ndef(\accvalues, {              
    |input=0|
    AnalogIn.kr(0);
});

r = fork{
	inf.do {
		var volume = Ndef(\accvalues).bus.getSynchronous;
		~n.sendMsg('/accxyz', volume.postln);
		(1/20).wait;
	}
};
r.play;


OSCdef(\acc, {
	| msg, time, addr, port |
	var x, y, z, sig, cutoff, ampval;
	msg.postln;
}, '/accxyz');


};

ServerQuit.add({ 0.exit }); // quit if the button is pressed






//INITIAL E.G. from sc dox
//LOOK THE ONE BELOW===========================
//THIS WORKS BUT I GET NO VALUES FROM ANALOG IN 

SynthDef("help-AnalogIn",{ arg out=7;
    //x
    Out.ar(6,
      SinOsc.ar( AnalogIn.ar( 0 ).exprange( 200, 5000 ), 0, 0.1 )
    );
    //y
    Out.ar(7,
      Saw.ar( AnalogIn.ar( 1 ).exprange( 200, 5000 ), 0.05 )
    );
    //z
    Out.ar(6, VarSaw.ar( AnalogIn.ar( 2 ).exprange( 400, 10000 ), mul:0.1 )!2)
}).play;










//TESTBELATESTBELATESTBELATESTBELATESTBELATESTBELATESTBELA
//Testing -- send rand vals n more
//=====================================================================
//send random coordinates to bela via osc
~n = NetAddr("localhost", 57120)
//:

r = fork{
	var x, y, z;
    //x
    x = {SinOsc.ar()}.play;//AnalogIn.ar(0);
    //x.poll;
    ~freq = x.poll;
    ~freq.poll;
    ~n.sendMsg('/accxyz', ~freq);
};

r.play

//:
~n = NetAddr("192.168.0.101", 57120);

Ndef(\accvalues, {              
    |input=0|
    AnalogIn.ar(0);
});

r = fork{
	inf.do {
		var volume = Ndef(\accvalues).bus.getSynchronous;
		~n.sendMsg('/accxyz', volume.postln);
		(1/20).wait;
	}
};
r.play;

//:
//on mac
~n = NetAddr("localhost", 57120);
~n.sendMsg('/accxyz', rrand(-10, 10), rrand(10, -10));
//:
OSCdef(\acc, {
	| msg, time, addr, port |
	var x, y, z, sig, cutoff, ampval;
	
	msg.postln;

}, '/accxyz');

//: Bela tests


