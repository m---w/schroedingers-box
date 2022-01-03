"Loading Trigger Logic (server-logic) ... ".post;


/*===================== RANDOMIZATION AND MAPPING FUNCTIONS =====================*/

~chooseAddSound = {
	// set new sample ID (random from array, but not same as previous)
	~lastAddSoundID = ~addSoundIndArray[~addSoundIndArray.rejectIndices({|i| i==~lastAddSoundID})].choose;
};


~randRate = {
	exprand(q[\playbackRand], q[\playbackRand].reciprocal); // random playback rate on exponential scale
	// if playbackRand is 2.0, then rate will be random between 0.5 and 2.0.
};


~randAddDelay = {
	rrand(q[\secondaryMinDel], q[\secondaryMaxDel]);
};


// Secondary sound
~maybeNewSecondarySound = {
	if(x[\secondary].isPlaying.not && ~addsound && ~secondaryPossible){
		~onsetCounter = ~onsetCounter + 1; // increment onset counter

		// Random decision (tune inMin and inMax to set minimum and maximum number of hits for 0% and 100% chance, respectively)
		if( ~onsetCounter.lincurve(inMin: q[\secondaryMinCount], inMax: q[\secondaryMaxCount], outMin: 0.0, outMax: 1.0, curve: q[\secondaryCountCurve], clip: \minmax).coin ) {
			// Trigger new secondary sound
			p.secondary[\bufnum] = ~soundcat_sum[~chooseAddSound.()];
			p.secondary[\rate] = ~randRate.();
			~secondaryPossible = false; // block secondary sound triggers until the synth has started
			fork{
				~randAddDelay.().wait;
				x[\secondary] = Synth.new(\secondary, p.secondary.asKeyValuePairs, addAction: \addToHead).register;
				if(~debugSound, {
					"Secondary sound started.".postln;
				});
				~secondaryPossible = true; // don't block anymore. Synth is already playing.
			};
			~onsetCounter = 1; // reset onset counter to 1 (so that there is already some small chance to directly trigger secondary sound again next time
		};

	};
};


~maybeTriggerOutcome = {
	if(~outcome&&~outcomePossible){
		if(p.primary[\vel]>q[\breakingThreshold]){
			// 1. Release all primary sounds
			v.set([\gate, 0], lat: nil);
			// 2. Trigger new breaking sound
			p.outcome[\vel] = p.primary[\vel]; // set outcome velocity equal to primary velocity
			p.outcome[\bufnum] = ~soundcat_sum[~chooseAddSound.()]; // choose random sample
			p.outcome[\rate] = ~randRate.(); // choose random playback rate
			x[\outcome] = Synth.new(\outcome, p.outcome.asKeyValuePairs, addAction: \addToHead); // create synth
			// ~outcomePossible = false; // outcome not possible anymore // WARNING: outcome is always possible!
		};
	};
};


/*===================== TRIGGER LOGIC =====================*/



// ONSET DETECTION
~oscReceiverOD = OSCFunc({ |msg, time|
	var id = msg[2];
	var val = msg[3];

	// trigger only if preset other than 0!
	if(~preset>0, {

		// Triggering, Cancelling, and Velocity update LOGIC
		switch (id,
			1, { // TBOD trigger new
				p.primary[\vel] = val;
				~maybeTriggerOutcome.(); // maybe trigger breaking sound
				~maybeNewSecondarySound.(); // maybe trigger new secondary sound
				if(~debugOnsets, {
					("TBOD: new onset. Vel:"+val).postln;
				});
			},
			// Source Localization:
			4, { // Velocity update, Channel 1
				~globalvels[0] = val;
			},
			5, { // Velocity update, Channel 2
				~globalvels[1] = val;
			},
			6, { // Velocity update, Channel 3
				~globalvels[2] = val;
			},
			7, { // Velocity update, Channel 4
				~globalvels[3] = val;
				if(~debugSourcePos, {
					("Source Localization: Velocities (dB rel to mean):"+(~globalvels/~globalvels.mean).ampdb.round(1.0)).postln;
				});
			};
		);

	});

},'/tr', s.addr);

"done.".postln;