fork{
	// initialize the midi client
	MIDIClient.init;
	// connect all the possible inputs
	MIDIIn.connectAll;
	1.wait;
	"MIDI initialised".postln;
	//=======================================
	//FIRST EVALUATE LATIN SQUARE
	//to initialise ~experimentOrder variable
	//=======================================

	// walk through the sounds: participant: latin square order
	//check
	//~experimentOrder[0];

	//initialisation
	//has to be -1 => array (0..55)
	//first press is 0 - first sound
	~sample = -1;

	//load latin square
	//update it when sounds are completed
	~experimentOrder =
	// -------- start -----------
	[
		[ 9, 6, 3, 8, 7, 1, 0, 5, 2, 4 ],
		[ 2, 8, 9, 5, 3, 4, 7, 1, 0, 6 ],
		[ 3, 4, 7, 6, 0, 5, 2, 8, 9, 1 ],
		[ 4, 9, 1, 2, 5, 7, 8, 0, 6, 3 ],
		[ 7, 1, 0, 4, 2, 8, 9, 6, 3, 5 ],
		[ 5, 7, 8, 3, 6, 2, 4, 9, 1, 0 ],
		[ 0, 5, 2, 1, 9, 6, 3, 4, 7, 8 ],
		[ 6, 2, 4, 0, 1, 3, 5, 7, 8, 9 ],
		[ 8, 0, 6, 7, 4, 9, 1, 3, 5, 2 ],
		[ 1, 3, 5, 9, 8, 0, 6, 2, 4, 7 ]
	]
	// -------- end -----------
	;
	

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

	"Big red button initialised".postln;
}