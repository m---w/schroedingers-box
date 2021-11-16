// initialize the midi client
MIDIClient.init;

// connect all the possible inputs
MIDIIn.connectAll;


MIDIdef.cc(\bigredbutton, {
	| ...args|

	args.postln;
	
	
}, 16); // match cc 1
