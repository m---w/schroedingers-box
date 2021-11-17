// initialize the midi client
MIDIClient.init;

// connect all the possible inputs
MIDIIn.connectAll;


//=======================================
//FIRST EVALUATE LATIN SQUARE
//to initialise ~experimentOrder variable
//=======================================

//: walk through the sounds: participant: latin square order
//check
~experimentOrder[0];

//initialisation
//~participant_id = 0;
//has to be -1 => array (0..55)
//first press is 0 - first sound
~sample = -1;

//MIDIdef
MIDIdef.cc(\bigredbutton, {
	| ...args|
	var next, val;
	
	//args.postln;
	val = args[0];

	//evaluate: when pressed 
	if (val == 0){
		if (~sample > (~experimentOrder[e.participantID].size -1)){
			//~sample = 0;
			"all samples were completed -- invite next participant".postln;
		}{
			//participant_id at which sample
			next = ~experimentOrder[e.participantID].at(~sample.max(0));
			//if sample = -1 make it 0
			if(~sample == (-1)){~sample = 0};
			("sample "++next).postln;
			n.sendMsg('/soundpick/2', \sam_num, next);
			
			e[\preset] = next;
			{~gui.upd;}.defer;		
			~sample = ~sample + 1;
		};
	};
	
}, 16); // match cc 1
//:

n = NetAddr("192.168.185.50", 57120);
//:
OSCdef(\participant_id, {
	| msg |
	var id;
	id = msg[1];
	id.postln;
	//update participant id value
	~participant_id = id;
}, '/participant_id')

//:


//tester, receive sample num change
OSCdef(\test, {
	| ...args |
	args.postln;
}, '/soundpick/2')






