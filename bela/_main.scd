/*
Schroedinger's Box
Main SuperCollider Patch
2021 Jason Svoronos-Kanavas, Marian Weger
*/

/*===================== BELA SETUP =====================*/

s = Server.default;
~hostname = "hostname".unixCmdGetStdOut.replace("\n","").asSymbol; // get system hostname
~path = PathName(thisProcess.nowExecutingPath).pathOnly; // current path


// Set up options
if(~hostname==\bela, { // If running on Bela
	~debugMode = false;
	s.options.numAnalogInChannels = 4;
	s.options.numAnalogOutChannels = 4;
	s.options.numDigitalChannels = 0;
	s.options.maxLogins = 4;
	s.options.blockSize = 32;
	s.options.numInputBusChannels = 4;
	s.options.numOutputBusChannels = 8;
	n = [ NetAddr("192.168.0.101", 57120), NetAddr("192.168.0.102", 57120), NetAddr("192.168.0.103", 57120) ]; // set GUI addresses
	"Bela recognized itself as Bela.".postln;
}, { // If running elsewhere (debug)
	~debugMode = true;
	s.options.numInputBusChannels = 4;
	s.options.numOutputBusChannels = 8;
	n = [ NetAddr("localhost", 57120) ];
	"No Bela detected. --> Debug mode.".postln;
});


/*===================== VARIABLE INITIALIZATIONS =====================*/

// Dictionaries
x = (); // synth dictionary
p = (); // parameter dictionary
p.tt = (); // test tone parameters
p.primary = (); // primary sound parameters
p.secondary = (); // secondary sound parameters
p.outcome = (); // outcome sound parameters
p.od = (); // onset detection parameters
p.master = (); // master parameters
q = (); // other parameters

// Variable Init
~tbodTriggered = false; // flag to store if TBOD has triggered
~fbodAgrees = false; // flag to store if FBOD agreed with TBOD
~debugOnsets = false; // debug printing for onset detection
~debugSourcePos = false; // debug printing for sound localization
~debugSound = false; // debug printing for sound triggering
~secondaryPossible = true; // flag used in secondary sound logic
~globalvels = 0.0!4; // init global velocities
~globalvel = 0.0; // init velocity
~sourcePos = 0.0!2; // init source position


/*===================== SOUND SELECTION =====================*/


OSCdef(\preset, { | msg, time |
	~preset = msg[1].asInteger; // set preset
	("New sound selected:"+~preset).postln; // notify

	// free everything that is playing
	x[\tt].free;
	x[\secondary].free;
	x[\outcome].free;
	v.free; // free previous voicer instance

	// load default settings (these may be defined in the preset)
	~addsound = false; // secondary sound on/off
	~outcome = false; // outcome sound on/off
	~voices = 2; // number of simultaneous voices (polyphony)
	~ampfactor = 0.0; // primary sound level
	~ampfactorcat = inf.neg; // secondary sound level
	~ampfactoroutcome = inf.neg; // outcome sound level
	~outcomePossible = true; // outcome didn't happen yet?
	~secondaryCutoff = 20000.0; // cutoff for secondary sound
	~onsetCounter = 0; // onset counter (for triggering secondary sound)
	~sound.do{|item| if(item.notNil, {item.free})}; // free buffers of primary sounds
	~soundcat_sum.do{|item| if(item.notNil, {item.free})}; // free buffers of secondary sounds
	~combFilterDryWet = 1.0.neg; // dry/wet for comb filter
	~secondaryMaxCount = 7; // secondary max count
	~hpfPrimary = 20.0; // default value for highpass filter of primary sound

	// Load preset
	if(~preset > 0){
		(~path+/+"presets/sound"++~preset.asInteger ++".scd").standardizePath.load; // load preset file
	}{
		// Notify if no preset was selected
		"No preset selected. Press the button to start!".postln;
		~sound = [~dummybuffer, ~dummybuffer];
		~soundcat_sum = [~dummybuffer, ~dummybuffer];
	};

	// QUICK HACK: DEACTIVATE COMB FILTER:
	~combFilterDryWet = 1.0.neg; // dry/wet for comb filter

	// init primary sound
	p.primary[\level] = ~ampfactor; // map preset variable to synth variable
	p.primary[\combFiltDryWet] = ~combFilterDryWet; // map preset variable to synth variable
	~soundSize = ~sound.size; // number of primary sounds in this preset
	~soundIndArray = (0..(~soundSize-1)); // array of primary sound indices
	~lastSoundID = ~soundIndArray.choose; // choose a random start index
	v = Voicer.new(voices: ~voices, things: \primary, bus: p.primary[\busnum], addAction: \addToHead); // start new voicer
	v.latency = nil; // set latency of the voicer. nil means as soon as possible.
	v.stealer = \preferLate; // set voice stealing algorithm

	// init master
	p.master[\hpfPrimary] = ~hpfPrimary; // map preset variable to synth variable
	x[\master].set([\hpfPrimary, p.master[\hpfPrimary]]); // set hpf cutoff of primary sound in master synth

	// init secondary sound
	p.secondary[\level] = ~ampfactorcat;
	p.secondary[\upperCutoff] = ~secondaryCutoff;
	p.secondary[\secondaryMaxCount] = ~secondaryMaxCount;
	if(~addsound, {
		~addSoundSize = ~soundcat_sum.size; // number of secondary sounds in this preset
		~addSoundIndArray = (0..(~addSoundSize-1)); // array of secondary sound indices
		~lastAddSoundID = ~addSoundIndArray.choose; // choose a random start index
	});

	// init outcome sound
	p.outcome[\level] = ~ampfactorcat; // TODO: separate level variable for outcome in presets
	// p.outcome[\level] = ~ampfactoroutcome;
	if(~outcome, {
		~addSoundSize = ~soundcat_sum.size; // number of secondary sounds in this preset
		~addSoundIndArray = (0..(~addSoundSize-1)); // array of secondary sound indices
		~lastAddSoundID = ~addSoundIndArray.choose; // choose a random start index
	});

	// update remote GUI
	n.do{|item| item.sendMsg(\bela, \primaryDB, p.primary[\level]) };
	n.do{|item| item.sendMsg(\bela, \secondaryDB, p.secondary[\level]) };
	n.do{|item| item.sendMsg(\bela, \outcomeDB, p.outcome[\level]) };
	n.do{|item| item.sendMsg(\bela, \secondaryCutoff, p.secondary[\upperCutoff]) };
	n.do{|item| item.sendMsg(\bela, \combFiltDryWet, p.primary[\combFilterDryWet]) };
	n.do{|item| item.sendMsg(\bela, \hpfPrimary, p.master[\hpfPrimary]) };
	n.do{|item| item.sendMsg(\bela, \secondaryMaxCount, p.secondary[\secondaryMaxCount]) };

	//finish
	// if(~preset>=666){s.freeAll};

},'/preset');


/*===================== GUI Control / OSC Receivers =====================*/

(~path+/+"oscReceivers.scd").standardizePath.load; // load OSC receivers


/*===================== SOUND TRIGGERING =====================*/

(~path+/+"triggerLogic.scd").standardizePath.load; // load trigger logic


/*===================== WAIT FOR SERVER =====================*/

s.waitForBoot{


	/*===================== BUS AND BUFFER ALLOCATIONS =====================*/

	// allocate busses
	p.primary[\busnum] = Bus.audio(s, numChannels: 1);
	p.secondary[\busnum] = Bus.audio(s, numChannels: 1);
	p.outcome[\busnum] = Bus.audio(s, numChannels: 1);

	// map also to master busses
	p.master[\primaryBus] = p.primary[\busnum];
	p.master[\secondaryBus] = p.secondary[\busnum];
	p.master[\outcomeBus] = p.outcome[\busnum];

	// allocate dummy buffer that will be used by default
	~dummybuffer = Buffer.alloc(s, 64, bufnum: 0);

	// load chirp into buffer
	p.tt[\bufnum] = Buffer.read(s, (~path+/+"chirp/chirp_"++switch(s.sampleRate.round.asInteger, 44100, "7.2s_44.1kHz", 48000, "6.6s_48kHz")++"_14_octaves_1_fadein_0_fadeout_24bit.wav").standardizePath);

	// Load Impulse Response for Equalization, to be used with PartConv
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

	// test recorder
	q.testRecBuf = Buffer.alloc(s, 48000*30, 4); // allocate a disk i/o buffer


	/*===================== SYNTHDEFS =====================*/

	(~path+/+"synthdefs.scd").standardizePath.load; // load synth defs


	/*===================== MAIN =====================*/

	1.wait; // wait a second

	x[\master] = Synth.new(\master, p.master.asKeyValuePairs, addAction: \addToTail).register; // start master synth
	x[\od] = Synth.new(\od, p.od.asKeyValuePairs, addAction: \addToHead).register; // start onset detection synth

	// request parameters from GUI
	n.do{|item| item.sendMsg(\bela, \booted) }; // send request via OSC to all addresses

	"Main Patch READY.".postln;
};


/*===================== QUIT =====================*/

if(~hostname==\bela, { // If running on Bela
	ServerQuit.add({ 0.exit }); // quit if the button is pressed
});
