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
    AnalogIn.kr(0);
});

Ndef(\yaccvalues, {              
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

OSCdef(\accv, {
	| msg, time, addr, port |
	var x, y, z, sig, cutoff, ampval;
	
	//calibralisation
	x = msg[1].linlin(0.331, 0.48, -1.0, 1.0);
	y = msg[2].linlin(0.32, 0.48, -1.0, 1.0);
	[x,y].postln;

}, '/accxyz');


};

ServerQuit.add({ 0.exit }); // quit if the button is pressed



