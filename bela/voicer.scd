"Loading Voicer (server-logic) ... ".post;


// Voice Allocation Synth. Needs to be re-defined on preset load.
SynthDef(\voicer, {
	arg
	onsetBus = 0,
	primaryCtlBus = 0,
	gateBus = 0,
	eqMinFreq = 1000.0,
	eqMaxFreq = 5000.0,
	slMaxPlaybackRate = 1.1;

	var
	bufnums = ~soundBufnums,
	voices = ~voices,
	slMaxPlaybackRateR = slMaxPlaybackRate.reciprocal,
	onset, gate, pos, bufnum, nextVoice, eqFreqs, rate;

	// get onset trigger and position [gate/vel, posx, posy]
	onset = In.ar(onsetBus, numChannels: 3);

	// shortcuts for gate and pos
	pos = onset[1..2]; // position [x,y] (between -1 and 1)
	gate = onset[0]; // gate and velocity signal
	// pos = DC.ar(0.0)!2; // pos simulator
	// gate = LFPulse.ar(freq: 0.5, width: 0.5, mul: 0.01); // trigger simulator

	// Parameter mapping: eqFreqs, rate
	eqFreqs = Clip.ar(LinExp.ar(pos, srclo: -1.0, srchi: 1.0, dstlo: eqMinFreq, dsthi: eqMaxFreq), lo: eqMinFreq, hi: eqMaxFreq); // map position to filter frequency
	rate = Clip.ar(LinExp.ar(pos.sum, srclo: -2.0, srchi: 2.0, dstlo: slMaxPlaybackRateR, dsthi: slMaxPlaybackRate), lo: slMaxPlaybackRateR, hi: slMaxPlaybackRate); // map position to playback speed

	// Random sample selection
	bufnum = Demand.ar(gate, 0, Dxrand(list: bufnums, repeats: inf)); // get random buffer number (no repetition)

	// Write voice parameters: [bufnum, rate, eqFreq1, eqFreq2]
	Out.ar(primaryCtlBus, [bufnum, rate, eqFreqs[0], eqFreqs[1]]); // write parameters

	// Voice-allocation Logic / Gate logic
	nextVoice = Stepper.ar(gate, 0, min: gateBus, max: gateBus+voices-1); // next voice index
	Out.ar(gateBus, Latch.ar(gate, gate)!voices); // set all gates to the velocity
	ReplaceOut.ar(nextVoice, DC.ar(0.0)); // set gate of next voice to 0 (trigger release)

}).add;

"done.".postln;