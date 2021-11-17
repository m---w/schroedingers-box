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
//has to be -1 => array (0..55)
//first press is 0 - first sound
~sample = -1;

//MIDIdef
MIDIdef.cc(\bigredbutton, {
	| ...args|
	var next, val;
	//0-127
	val = args[0];

	//evaluate: when pressed 
	if (val == 0){
		if (~sample > (~experimentOrder[e.participantID].size -1)){
			"all samples were completed -- invite next participant".postln;
		}{
			//participant_id at which sample
			next = ~experimentOrder[e.participantID].at(~sample.max(0));
			//if sample = -1 make it 0 and load it
			if(~sample == (-1)){~sample = 0};
			("sample number: "++next).postln;
			n.sendMsg('/soundpick/2', \sam_num, next);
			
			e[\preset] = next;
			{~gui.upd;}.defer;		
			~sample = ~sample + 1;
		};
	};
	
}, 16);
//:
