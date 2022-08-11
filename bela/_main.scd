/*
	Schroedinger's Box
	Main SuperCollider Patch
	2021 Jason Svoronos-Kanavas, Marian Weger
*/

/*===================== BELA SETUP =====================*/

s = Server.local;
~hostname = "hostname".unixCmdGetStdOut.replace("\n","").asSymbol; // get system hostname
~path = PathName(thisProcess.nowExecutingPath).pathOnly; // current path

~serverLogic = true; // server-logic (fast) or sclang-logic (slow)


// Set up options
if(~hostname==\bela, { // If running on Bela
	~debugMode = false;
	s.options.sampleRate = 48000;
	s.options.numAnalogInChannels = 4;
	s.options.numAnalogOutChannels = 4;
	s.options.numDigitalChannels = 0;
	s.options.headphoneLevel = 0;
	s.options.pgaGainLeft = 0;
	s.options.pgaGainRight = 0;
	s.options.speakerMuted = 1;
	s.options.dacLevel = 0; // sets the gain of the dac to 0 dB
	s.options.adcLevel = 0; // sets the gain of the adc to 0 dB
	s.options.numMultiplexChannels = 0; // do not enable multiplexer channels
	s.options.maxLogins = 4;
	s.options.blockSize = 32;
	s.options.hardwareBufferSize = 32;
	s.options.numInputBusChannels = 4;
	s.options.numOutputBusChannels = 4;
	n = [ NetAddr("192.168.0.101", 57120), NetAddr("192.168.0.102", 57120), NetAddr("192.168.0.103", 57120) ]; // set GUI addresses
	"Bela recognized itself as Bela.".postln;
}, { // If running elsewhere (debug)
	~debugMode = true;
	s.options.numInputBusChannels = 4;
	s.options.numOutputBusChannels = 4;
	n = [ NetAddr("localhost", 57120) ];
	"No Bela detected. --> Debug mode.".postln;
});


/*===================== VARIABLE INITIALIZATIONS =====================*/

// Dictionaries
x = (); // synth dictionary
p = (); // parameter dictionary
p.tt = (); // test tone parameters
p.voicer = ();
p.primary = (); // primary sound parameters
p.secondary = (); // secondary sound parameters
p.outcome = (); // outcome sound parameters
p.od = (); // onset detection parameters
p.master = (); // master parameters
q = (); // other parameters

// Variable Init
//~tbodTriggered = false; // flag to store if TBOD has triggered
//~fbodAgrees = false; // flag to store if FBOD agreed with TBOD
~measurement = false; // toggle for measurement mode
~debugOnsets = false; // debug printing for onset detection
~debugSourcePos = false; // debug printing for sound localization
~debugSound = false; // debug printing for sound triggering
~secondaryPossible = true; // flag used in secondary sound logic
~maxVoices = 3; // maximum number of allocated voices
~minVoices = 2; // minimum number of allocated voices (2 is basically one voice, but with smooth fadeout)
~presetIsReady = true; // flag to say if a preset can be loaded

// Init variables that are unique to server or sclang logic
if(~serverLogic, {
	// server logic variables
}, {
	// sclang logic variables
	~globalvels = 0.0!4; // init global velocities
	~globalvel = 0.0; // init velocity
	~sourcePos = 0.0!2; // init source position
});



// scan for presets
q[\presetIDs] = Array.new(1000); // Warning: hard-coded fixed size 1000, should be enough for all time!
PathName.new((~path+/+"presets").standardizePath).files.do{ |item|
	var path = item;
	var filename = item.fileNameWithoutExtension;
	if(filename.contains("sound"), {
		q[\presetIDs].add(PathName.new(filename).endNumber);
	});
};
q[\presetIDs] = q[\presetIDs].sort; // Get list of found presets in ascending order


/*===================== SOUND SELECTION =====================*/


OSCdef(\preset, { | msg, time | if(~presetIsReady, { {
	~presetIsReady = false;

	~preset = msg[1].asInteger; // set preset
	("New sound selected:"+~preset).postln; // notify

	// free everything that is playing
	//x[\tt].free;
	//x[\secondary].free;
	//x[\outcome].free;
	s.freeAll;
	s.sync;

	// load default settings (these may be defined in the preset)
	~addsound = false; // secondary sound on/off
	~outcome = false; // outcome sound on/off
	~voices = 3; // number of simultaneous voices (polyphony)
	~ampfactor = 0.0; // primary sound level
	~ampfactorcat = inf.neg; // secondary sound level
	~ampfactoroutcome = inf.neg; // outcome sound level
	~outcomePossible = true; // outcome didn't happen yet?
	~secondaryCutoff = 20000.0; // cutoff for secondary sound
	~onsetCounter = 0; // onset counter (for triggering secondary sound)
	~sound.do{|item| item.free }; // free buffers of primary sounds
	~soundcat_sum.do{|item| item.free }; // free buffers of secondary sounds
	~dummybuffer.free;
	~dummybuffer = Buffer.alloc(s, 32, bufnum: 0);
	~secondaryMaxCount = 6; // secondary max count
	~hpfPrimary = 20.0; // default value for highpass filter of primary sound
	~sound = [~dummybuffer, ~dummybuffer];
	~soundcat_sum = [~dummybuffer, ~dummybuffer];
	~presetName = "---";

	// Load preset
	if(q[\presetIDs].includes(~preset)){
		(~path+/+"presets/sound"++~preset.asInteger ++".scd").standardizePath.load; // load preset file
	}{
		// Notify if no preset was selected
		"No valid preset selected. Press the button to start!";
		~presetName = "invalid";
	};

	// fix number of voices
	~voices = ~voices.max(~minVoices).min(~maxVoices); // clip number of voices

	// init primary sound
	p.primary[\level] = ~ampfactor.dbamp; // map preset variable to synth variable
	// p.primary[\combFiltDryWet] = ~combFilterDryWet; // map preset variable to synth variable
	// p.primary[\eqGain] = ~eqGain;
	~soundSize = ~sound.size; // number of primary sounds in this preset
	~soundIndArray = (0..(~soundSize-1)); // array of primary sound indices
	~soundBufnums = ~sound.collect{|item| item.bufnum}; // array of bufnums for sound samples of this preset
	~lastSoundID = ~soundIndArray.choose; // choose a random start index

	// measurement mode
	if(~measurement, {
		p.od[\inchannels] = [0,0,2,3]; // 2nd channel (ch. 1) is used for measurement and thus deactivated for onset detection
	},{
		p.od[\inchannels] = [0,1,2,3]; // normal
	});


	// START SIGNAL PROCESSING (either server-side or sclang logic)
	if(~serverLogic, { // server logic

		// Workaround against noise bursts on preset change
		/*
		s.sync;
		~sound.do{|item|
			var end = item.numFrames-1;
			item.set(0, 0.0, end, 0.0);
		};
		~soundcat_sum.do{|item|
			var end = item.numFrames-1;
			item.set(0, 0.0, end, 0.0);
		};
		s.sync;
		*/

		// free voicer and individual voices
		//x[\primary].do{|item| item.free};
		//x[\voicer].free;
		//s.freeAll;
		//s.sync;

		// start onset detection
		x[\od] = Synth.new(\od, p.od.asKeyValuePairs, addAction: \addToHead).register; // start onset detection synth

		1.wait;

		// re-load voicer SynthDef (found no other way to set number of voices dynamically)
		(~path+/+"voicer.scd").standardizePath.load;
		s.sync;

		1.wait;

		// mute all outputs
		//~tempLevel = p[\primary][\level];
		//p[\primary][\level] = inf.neg;
		//~tempMasterLevel = p[\master][\masterLevel];
		//p[\master][\masterLevel] = inf.neg;

		// create new voicer and voices
		x[\voicer] = Synth.after(x[\od], \voicer, p[\voicer].asKeyValuePairs).register;
		s.sync;

		1.wait;

		x[\primary] = ~voices.collect{|i| Synth.after(x[\voicer], \primaryVoice, [\voiceID, i]++p[\primary].asKeyValuePairs).register};
		s.sync;

		1.wait;

		// start master
		x[\master] = Synth.new(\master, p.master.asKeyValuePairs, addAction: \addToTail).register; // start master synth
		s.sync;

	}, { // SCLang logic

		//s.freeAll;
		//s.sync;



		x[\od] = Synth.new(\od, p.od.asKeyValuePairs, addAction: \addToHead).register; // start onset detection synth
		x[\master] = Synth.new(\master, p.master.asKeyValuePairs, addAction: \addToTail).register; // start master synth


		// free old voicer instance
		v.free;

		// new voicer setup
		v = Voicer.new(voices: ~voices, things: \primary, bus: p.primary[\busnum], addAction: \addToHead); // start new voicer
		v.latency = nil; // set latency of the voicer. nil means as soon as possible.
		v.stealer = \preferLate; // set voice stealing algorithm


	});

	// init master
	p.master[\hpfPrimary] = ~hpfPrimary; // map preset variable to synth variable
	x[\master].set([\hpfPrimary, p.master[\hpfPrimary]]); // set hpf cutoff of primary sound in master synth

	// init secondary sound
	p.secondary[\level] = ~ampfactorcat.dbamp;
	p.secondary[\upperCutoff] = ~secondaryCutoff;
	p.secondary[\secondaryMaxCount] = ~secondaryMaxCount;
	if(~addsound, {
		~addSoundSize = ~soundcat_sum.size; // number of secondary sounds in this preset
		~addSoundIndArray = (0..(~addSoundSize-1)); // array of secondary sound indices
		~lastAddSoundID = ~addSoundIndArray.choose; // choose a random start index
	});

	// init outcome sound
	p.outcome[\level] = p.secondary[\level]; // TODO: separate level variable for outcome in presets
	// p.outcome[\level] = ~ampfactoroutcome.dbamp;
	if(~outcome, {
		~addSoundSize = ~soundcat_sum.size; // number of secondary sounds in this preset
		~addSoundIndArray = (0..(~addSoundSize-1)); // array of secondary sound indices
		~lastAddSoundID = ~addSoundIndArray.choose; // choose a random start index
	});

	// update remote GUI
	n.do{|item| item.sendMsg(\bela, \primaryDB, p.primary[\level].ampdb) };
	n.do{|item| item.sendMsg(\bela, \secondaryDB, p.secondary[\level].ampdb) };
	n.do{|item| item.sendMsg(\bela, \outcomeDB, p.outcome[\level].ampdb) };
	// n.do{|item| item.sendMsg(\bela, \secondaryCutoff, p.secondary[\upperCutoff]) };
	// n.do{|item| item.sendMsg(\bela, \combFiltDryWet, p.primary[\combFilterDryWet]) };
	// n.do{|item| item.sendMsg(\bela, \eqDryWet, p.primary[\eqDryWet]) };
	n.do{|item| item.sendMsg(\bela, \hpfPrimary, p.master[\hpfPrimary]) };
	n.do{|item| item.sendMsg(\bela, \secondaryMaxCount, p.secondary[\secondaryMaxCount]) };
	n.do{|item| item.sendMsg(\bela, \presetName, ~presetName) };

	//finish
	// if(~preset>=666){s.freeAll};


	//0.25.wait;
	//s.sync;
	// set levels again
	//p[\primary][\level] = ~tempLevel;
	//x[\primary].do{|item| item.set([\level, p[\primary][\level]])};
	//p[\master][\masterLevel] = ~tempMasterLevel;
	//x[\master].set([\masterLevel, p[\master][\masterLevel]]);

	~presetIsReady = true;
}.fork})},'/preset');


/*===================== GUI Control / OSC Receivers =====================*/

(~path+/+"oscReceivers.scd").standardizePath.load; // load OSC receivers


/*===================== SOUND TRIGGERING =====================*/


// Same for both versions

/*--------------- Same for both versions: Randomization, mapping functions, yield and secondary sound ----------------*/

~chooseAddSound = {
	// set new sample ID (random from array, but not same as previous)
	~lastAddSoundID = ~addSoundIndArray[~addSoundIndArray.rejectIndices({|i| i==~lastAddSoundID})].choose;
};


// random playback rate
~randRate = {
	exprand(q[\secondaryPlaybackRand], q[\secondaryPlaybackRand].reciprocal); // random playback rate on exponential scale
	// if playbackRand is 2.0, then rate will be random between 0.5 and 2.0.
};

/*
// random comb filtering
~randCombFreq = {
	exprand(q[\combFiltMaxFreq], q[\combFiltMinFreq]); // random frequency on exponential scale between min and max
};
*/


// random delay for starting secondary sound
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



// Yield sound
~maybeTriggerOutcome = {
	if(~outcome&&~outcomePossible){
		if(p.primary[\vel]>q[\breakingThreshold]){
			// 1. Release all primary sounds (only necessary for sclang logic, but does no harm for server logic
			//v.set([\gate, 0], lat: nil); // deactivated: primary will continue during yield
			// 2. Trigger new yield sound
			p.outcome[\vel] = p.primary[\vel]; // set outcome velocity equal to primary velocity
			p.outcome[\bufnum] = ~soundcat_sum[~chooseAddSound.()]; // choose random sample
			p.outcome[\rate] = ~randRate.(); // choose random playback rate
			x[\outcome] = Synth.new(\outcome, p.outcome.asKeyValuePairs, addAction: \addToHead); // create synth
			// ~outcomePossible = false; // outcome not possible anymore // WARNING: outcome is always possible!
		};
	};
};



/*--------------- Load either server or sclang logic ----------------*/

if(~serverLogic, {
	(~path+/+"triggerLogic_server-logic.scd").standardizePath.load; // load server-side trigger logic
}, {
	(~path+/+"triggerLogic_sclang-logic.scd").standardizePath.load; // load language-side trigger logic
});


/*===================== WAIT FOR SERVER =====================*/

s.waitForBoot{{

	/*===================== BUS AND BUFFER ALLOCATIONS =====================*/

	// allocate busses
	p.primary[\busnum] = Bus.audio(s, numChannels: 1);
	p.secondary[\busnum] = Bus.audio(s, numChannels: 1);
	p.outcome[\busnum] = Bus.audio(s, numChannels: 1);

	if(~serverLogic, {
		// allocate busses
		~onsetBus = Bus.audio(s, numChannels: 4); // init audio busses for onset busses [gate, vel, posx, posy]

		~primaryCtlBus = Bus.audio(s, numChannels: 3); // init audio busses for primary sound parameters [bufnum, rate, vel]
		~gateBus = Bus.audio(s, numChannels: ~maxVoices); // init audio busses for voice gates
		~updateBus = Bus.audio(s, numChannels: ~maxVoices); // init audio busses for voice update logic
		~velTrigBus = Bus.audio(s, numChannels: 1); // velTrig bus

		// map busses
		p.od[\onsetBus] = ~onsetBus.index;
		p.od[\velTrigBus] = ~velTrigBus.index;
		p.voicer[\onsetBus] = p.od[\onsetBus];
		p.voicer[\primaryCtlBus] = ~primaryCtlBus.index;
		p.voicer[\gateBus] = ~gateBus.index;
		p.voicer[\updateBus] = ~updateBus.index;
		p.primary[\primaryCtlBus] = p.voicer[\primaryCtlBus];
		p.primary[\gateBus] = p.voicer[\gateBus];
		p.primary[\velTrigBus] = p.od[\velTrigBus];
		p.primary[\updateBus] = p.voicer[\updateBus];
	});

	// map also to master busses
	p.master[\primaryBus] = p.primary[\busnum].index;
	p.master[\secondaryBus] = p.secondary[\busnum].index;
	p.master[\outcomeBus] = p.outcome[\busnum].index;

	// allocate dummy buffer that will be used by default
	~dummybuffer = Buffer.alloc(s, 32, bufnum: 0);

	// load chirp into buffer
	// p.tt[\bufnum] = Buffer.read(s, (~path+/+"chirp/chirp_"++switch(s.sampleRate.round.asInteger, 44100, "7.2s_44.1kHz", 48000, "6.6s_48kHz")++"_14_octaves_1_fadein_0_fadeout_24bit.wav").standardizePath);

	// Load Impulse Response for Equalization, to be used with PartConv
	/*
	p.master[\partConvFFTSize] = 4 * s.options.blockSize; // FFT size for the partitioned convolution. At least 4x blocksize.
	~irBuf = Buffer.read(s, (~path+/+"ir/2021-12-12_20-10-41-751_ex_ir_out_01_in_01.wav").standardizePath);
	s.sync;
	~irBufSize = PartConv.calcBufSize(p.master[\partConvFFTSize], ~irBuf);
	~irNumPartitions = PartConv.calcNumPartitions(p.master[\partConvFFTSize], ~irBuf); // for debugging only
	~irSpectrum = Buffer.alloc(s, ~irBufSize, 1);
	~irSpectrum.preparePartConv(~irBuf, p.master[\partConvFFTSize]);
	s.sync;
	~irBuf.free; // don't need time domain data anymore, just needed spectral version
	p.master[\irbufnum] = ~irSpectrum.bufnum;
	*/

	// test recorder
	// q.testRecBuf = Buffer.alloc(s, 960000, 5); // allocate a disk i/o buffer (20*48000 = 20s)


	/*===================== SYNTHDEFS =====================*/

	if(~serverLogic, {
		(~path+/+"synthdefs_server-logic.scd").standardizePath.load; // load synth defs
	}, {
		(~path+/+"synthdefs_sclang-logic.scd").standardizePath.load; // load synth defs
	});

	/*===================== MAIN =====================*/

	// 1.wait; // wait a second

	s.sync;

	//x[\master] = Synth.new(\master, p.master.asKeyValuePairs, addAction: \addToTail).register; // start master synth
	//x[\od] = Synth.new(\od, p.od.asKeyValuePairs, addAction: \addToHead).register; // start onset detection synth

	// request parameters from GUI
	n.do{|item| item.sendMsg(\bela, \booted) }; // send request via OSC to all addresses

	"Main Patch READY.".postln;
}.fork};


/*===================== QUIT =====================*/

if(~hostname==\bela, { // If running on Bela
	ServerQuit.add({ 0.exit }); // quit if the button is pressed
});
