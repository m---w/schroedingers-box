"Loading SynthDefs (server-logic) ... ".post;


SynthDef(\primaryVoice,{

	arg
	voiceID = 0,
	primaryCtlBus = 0,
	gateBus = 0,
	updateBus = 0,
	busnum = 0,
	velTrigBus = 0,
	//velEnvDur = 0.005,
	//velPeakLevel = 20.0,
	//velPeakMapZeroDB = 3.0.neg,
	//eqGain = 4.0,
	//eqRQ = 0.1,
	level = 0.0;

	var ctl, gate, sig, env, out, rate, bufnum, update, velTrig, amplitude;
	// var amplitude
	//var eqFreq1, eqFreq2,
	//var velPeakDB, velEnv;

	// inputs: voice parameters and voice gate
	//ctl = In.ar(primaryCtlBus, 4); // receive voice parameters [bufnum, rate, eqFreq1, eqFreq2]
	ctl = In.ar(primaryCtlBus, 3); // receive voice parameters [bufnum, rate, vel]
	update = In.ar(updateBus+voiceID, 1); // receive update gate of this ID
	gate = In.ar(gateBus+voiceID, 1); // receive voice gate of this ID
	velTrig = In.ar(velTrigBus, 1);

	// velTrig = DelayN.ar(update, 0.05, velDelay); // after TBOD trigger, wait for specified delay time, then trigger velocity


	// sample the voice parameters
	// amplitude = Latch.ar(gate, gate); // sample&hold for velocity amplitude
	// amplitude = (ctl[2]*update) + ((update.neg+1.0)*Latch.ar(ctl[2], velTrig*update)); // velocity amplitude
	amplitude = Gate.ar(ctl[2], Trig.ar(update, 0.0009));
	bufnum = Latch.ar(ctl[0], gate); // sample&hold for bufnum
	rate = Latch.ar(ctl[1], gate); // sample&hold for rate
	//eqFreq1 = Latch.ar(ctl[2], gate);
	//eqFreq2 = Latch.ar(ctl[3], gate);

	// sample playback
	// sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: rate*BufRateScale.kr(bufnum), trigger: gate, doneAction: 0); // play sample
	sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: rate, trigger: gate, doneAction: 0); // play sample

	// position-dependent filtering
	//sig = BPeakEQ.ar(sig, freq: eqFreq1, rq: eqRQ, db: eqGain);
	//sig = BPeakEQ.ar(sig, freq: eqFreq2, rq: eqRQ, db: eqGain.neg);

	// velocity-dependent filtering
	/* DEACTIVATED TO SAVE COMPUTING POWER
	velPeakDB = amplitude.ampdb.madd(velPeakLevel/velPeakMapZeroDB.neg, velPeakLevel).clip2(velPeakLevel);
	// velPeakDB = LinLin.ar(amplitude.ampdb, srclo: 2.0*velPeakMapZeroDB, srchi: 0.0, dstlo: velPeakLevelN, dsthi: velPeakLevel).clip2(velPeakLevel);
	velEnv = EnvGen.ar(Env.new(levels: [0.0, velPeakDB, 0.0], times: [0.0, velEnvDur], curve: \lin), gate: gate, doneAction: 0);
	sig = BHiShelf.ar(sig, freq: 7500.0, rs: 10.0, db: velEnv);
	*/

	// release envelope, velocity, and level
	env = Amplitude.ar(gate*amplitude, attackTime: 0.0, releaseTime: 0.1, mul: level); // envelope with instant attack and smooth release, apply master level
	out = sig * env; // apply velocity amplitude, envelope

	// mute first few ms of creation
	//out = out * EnvGen.kr(Env([0,0,1], [0.2, 0.05]), doneAction: 0);

	// output
	Out.ar(busnum, out); // play to bus

}).add;


// OUTCOME SOUND
SynthDef(\outcome,{

	arg
	busnum = 0,
	vel = 0.0,
	bufnum = 0,
	// rate = 1.0,
	level = 0.0;


	var sig, comb;

	sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: 1.0, trigger: 1.0, doneAction: 2); // play sample
	sig = (vel * level) * sig; // apply velocity and master level
	Out.ar(busnum, sig); // play to bus

}).add;


// SECONDARY SOUND
SynthDef(\secondary, {

	arg
	busnum = 0,
	bufnum = 0,
	// rate = 1.0,
	// upperCutoff = 500,
	level = 0.0;


	var sig;

	sig = PlayBuf.ar(numChannels: 1, bufnum: bufnum, rate: 1.0, trigger: 1.0, doneAction: 2); // play sample
	// sig = LPF.ar(sig, upperCutoff); // low-pass filter to simulate damping through box
	sig = sig * level; // apply amplitude
	Out.ar(busnum, sig);

}).add;


// MASTER BUS
SynthDef(\master, {

	arg
	primaryBus = 0,
	secondaryBus = 0,
	outcomeBus = 0,
	primaryLevel = 0.0,
	secondaryLevel = 0.0,
	outcomeLevel = 0.0,
	lpf = 20000.0,
	hpf = 80.0,
	// irbufnum = 0,
	// partConvFFTSize = 128,
	// eq = 1,
	masterLevel = inf.neg,
	hpfPrimary = 20;

	var primary, secondary, outcome, out;
	// var master;

	primary = Hip48.ar(In.ar(primaryBus, numChannels: 1), hpfPrimary) * primaryLevel; // read primary bus and apply level
	secondary = In.ar(secondaryBus, numChannels: 1) * secondaryLevel; // read secondary bus and apply level
	outcome = In.ar(outcomeBus, numChannels: 1) * outcomeLevel; // read outcome bus and apply level

	// master = primary + secondary + outcome; // just sum all sounds together

	// Equalization with inverse filter
	// out = (eq * PartConv.ar(master, fftsize: partConvFFTSize, irbufnum: irbufnum)) + ((1.0-eq) * master); // Partitioned convolution with impulse response of equalization filter, with bypass switch

	out = primary + secondary + outcome; // just sum all sounds together

	// mute first few ms of creation
	//out = out * EnvGen.kr(Env([0,0,1], [0.2, 0.05]), doneAction: 0);

	out = Lop48.ar(HPF.ar(out*masterLevel, hpf), lpf).tanh; // output filtering and protection
	Out.ar(0, out!4); // write same signal to all output channels

}).add;


// ONSET DETECTION
SynthDef(\od, {
	arg
	onsetBus = 0,
	velTrigBus = 0,
	tbThreshDB = 0.0,
	tbThreshLoDB = 0.0,
	//fbThreshDB = 0.0,
	//fbRelaxtime = 1.0,
	//fbFloorDB = -20.0,
	//fbMingap = 22,
	//fbMedianspan = 22,
	velDelay = 0.0009,
	tbRefPeriod = 0.03,
	tbLpf1Freq = 25.0,
	tbLpf2Freq = 25.0,
	tbHpfFreq = 4000.0,
	//cancelDel = 1.0,
	inchannels = #[0,1,2,3],
	inGain1 = 0.0,
	inGain2 = 0.0,
	inGain3 = 0.0,
	inGain4 = 0.0,
	slMaxRatioDB = 2.0,
	//velMapInMin = 0.001,
	velMapInMax = 0.1,
	velMapOutMin = 0.01,
	velMapOutMax = 1.0;


	var sigRaw, sig, sighpf, energies, lpf1, derivative, lpf2, tsub, tbTrig, velTrig, energy, tbVel, tbVels, sigRawAbss, pos, vel;
	// var chain, fbTrigKR, fbTrigAR;
	// var sampleDur = 1.1/SampleRate.ir; // duration of one audio sample, plus 10 percent safety
	// var nfft = 256; // FFT size in samples
	// var frameDur = (nfft/SampleRate.ir)*1.1; // duration of one fft frame in seconds, plus safety of 10 percent. 5.4ms at 48kHz and 256samp fft size.

	sigRaw = SoundIn.ar(inchannels) * [inGain1, inGain2, inGain3, inGain4]; // input channels
	// sigRawSum = sigRaw.sum; // mono mix version

	sigRawAbss = HPF.ar(sigRaw, 1500.0).abs; // velocity signal


	//=== TBOD ===
	sighpf = Hip48.ar(sigRaw, tbHpfFreq); // Highpass Filter. Turchet2018: 4000 for conga, 7500 for bongo/djembe/cajon
	// energies = sighpf.squared; // Squaring (get signal energy)
	energies = Teager.ar(sighpf); // Teager Operator = signal energy
	energy = energies.sum; // add up all energies
	lpf1 = Lop48.ar(energy, tbLpf1Freq); // Smoothing 1. Turchet2018: 25
	derivative = Slope.ar(lpf1); // 1st derivative = slope
	lpf2 = Lop48.ar(derivative, tbLpf2Freq); // Smoothing 2. Turchet2018: 25
	// tsub = (0.01 * lpf1 - lpf2).max(0); // trend subtraction (inspired from Coyote)
	//tsub = lpf2 - Median.ar(64, lpf2); // trend subtraction (inspired from Turchet2018: length 65 samples)
	// tsub = energy - lpf1;
	// tsub = energy - Median.ar(64, lpf1);
	tbTrig = Trig.ar(Schmidt.ar(lpf2, tbThreshLoDB, tbThreshDB), tbRefPeriod); // thresholding with high and low threshold
	//tbTrig = Trig.ar((tsub-tbThreshDB.dbamp).sign.max(0), tbRefPeriod); // simple thresholding, including a refractory period to prevent re-triggering within the given time
	//SendTrig.ar(tbTrig, id: 1, value: 0.0); // send TBOD trigger to language. ID 1 means TBOD. Value is first guess for velocity.

	//=== FAC: false alarm cancellation ===
	/*
	SendTrig.ar(DelayN.ar(tbTrig, 0.1, cancelDel*frameDur), id: 0, value: 0.0); // send FBOD cancel trigger to language. ID 0 means FBOD cancel (TBOD false alarm, FBOD correct rejection)
	*/

	//=== VD: velocity detection ===
	tbVels = RunningMax.ar(sigRawAbss, tbTrig).max(1e-16); // running max of input. reset at TBOD trigger.
	tbVel = tbVels.mean; // average all channels
	velTrig = DelayN.ar(tbTrig, 0.05, velDelay); // after TBOD trigger, wait for specified delay time, then trigger velocity
	vel = Clip.ar(tbVel * (velMapOutMax/velMapInMax), lo: velMapOutMin, hi: velMapOutMax); // map and clip velocity
	SendTrig.ar(velTrig, id: 1, value: vel); // send velocity value to language.


	//=== FBOD ===
	/*
	chain = FFT(LocalBuf(nfft), sigRawSum, hop: 0.25, wintype: 1); // Turchet2018: winsize 256, hopsize 64. Wintype 1 is Hann window.
	fbTrigKR = Onsets.kr(chain, threshold: fbThreshDB.dbamp, odftype: \rcomplex, relaxtime: fbRelaxtime, floor: fbFloorDB.dbamp, mingap: fbMingap, medianspan: fbMedianspan); // rcomplex is best. if it takes up too much cpu, then use power.
	fbTrigAR = T2A.ar(fbTrigKR, offset: 0);
	SendTrig.ar(fbTrigAR, id: 2, value: 0.0); // send FBOD trigger to language. ID 2 means FBOD.
	*/


	//=== SL: source localization ===
	// Position goes from -1 to +1.
	// Channel mapping:
	//  top left: 2
	//  top right: 3
	//  bottom left: 0
	//  bottom right: 1
	// guess source position from level differences (i.e., from amplitude ratios)
	/*pos = [
	// right vs. left
	Clip.ar(LinLin.ar([velsDB[3]-velsDB[2], velsDB[1]-velsDB[0]], srclo: slMinRatioDB, srchi: slMaxRatioDB, dstlo: -1.0, dsthi: 1.0), lo: -1.0, hi: 1.0).mean,
	// top vs. bottom
	Clip.ar(LinLin.ar([velsDB[2]-velsDB[0], velsDB[3]-velsDB[1]], srclo: slMinRatioDB, srchi: slMaxRatioDB, dstlo: -1.0, dsthi: 1.0), lo: -1.0, hi: 1.0).mean
	];*/

	pos = ((0.5*[
		// right vs. left
		((tbVels[3]+tbVels[1])/(tbVels[2]+tbVels[0])),
		// top vs. bottom
		((tbVels[2]+tbVels[3])/(tbVels[0]+tbVels[1]))
	]).ampdb/slMaxRatioDB).clip2(1.0);

	// Send Onset Trigger to Onset Bus
	// Out.ar(onsetBus, velTrig*Latch.ar([vel, pos[0], pos[1]], velTrig));
	Out.ar(onsetBus, [tbTrig, vel, pos[0], pos[1]]);

	Out.ar(velTrigBus, velTrig);

}).add;


// TEST TONE GENERATOR
SynthDef(\tt, {

	arg
	noiseMasterDB = -80.0,
	sineMasterDB = -80.0,
	testFreq = 400.0,
	toggleSine = 0.0,
	toggleNoise = 0.0,
	toggleMaster = 1.0,
	toggle1 = 0.0,
	toggle2 = 0.0,
	toggle3 = 0.0,
	toggle4 = 0.0,
	flip1 = 0.0,
	flip2 = 0.0,
	flip3 = 0.0,
	flip4 = 0.0,
	bufnum = 0,
	playChirp = 0.0;

	var noise = WhiteNoise.ar(noiseMasterDB.dbamp*toggleNoise); // white noise generator
	var sine = SinOsc.ar(testFreq, mul: sineMasterDB.dbamp*toggleSine); // sine tone generator
	var chirp = PlayBuf.ar(1, bufnum: bufnum, trigger: playChirp, doneAction: 0) * sineMasterDB.dbamp;
	var sig = (sine + noise + chirp) * toggleMaster; // monophonic test signal
	var flipToggles = [flip1, flip2, flip3, flip4].madd(2.0.neg,1.0); // flip phase switches
	var toggles = [toggle1, toggle2, toggle3, toggle4]; // channel state switches
	var sigArray = toggles*flipToggles*sig; // 4ch test signal

	Out.ar(0, (sigArray!2).flat); // play same signal to 1-4 and 5-8

}).add;

SynthDef(\testOnset, {
	arg
	vel = 0.0,
	onsetBus = 0,
	velTrigBus = 0,
	velDelay = 0.0009,
	testOnsetPosX = 0.0,
	testOnsetPosY = 0.0;

	var gate = EnvGen.ar(Env.step([0.0, 1.0, 0.0],[0.0, 0.05, 0.0]), doneAction: 2);
	ReplaceOut.ar(onsetBus, [gate, DC.ar(vel), DC.ar(testOnsetPosX), DC.ar(testOnsetPosY)]);
	Out.ar(velTrigBus, DelayN.ar(gate, 0.05, velDelay));

	SendTrig.ar(gate, id: 1, value: vel); // send velocity value to language.

}).add;



// Recorder
SynthDef(\recorder, {|buf=0,primaryBus=0|
	DiskOut.ar(buf, SoundIn.ar([0,1,2,3])++In.ar(primaryBus));
}).add;


"done.".postln;