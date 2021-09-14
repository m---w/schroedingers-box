//for_recording
fork{
	s.record("/Users/jsk/Desktop/sound1.wav");
	0.02.wait;
	Synth("boing", [\gate, 1]);
}
//: buffer_read
~sound = Buffer.read(s, "/Users/jsk/Desktop/sound1.wav")
~sound = Buffer.read(s, "/Users/jsk/Desktop/sound1.wav")
~sound.plot
//: playback

play{PlayBuf.ar(2, ~sound)}

//: sounds

//1
SynthDef(\boing, {
	| freq = 966, amp = 0.5, gate |
	var sig, env, out;
	sig = SinOsc.ar(XLine.kr(freq, freq/10, 1)) * SinOsc.kr(7);
	env = Env.perc(1, 1).kr(gate: gate, doneAction:2);
	out = sig * env;
	Out.ar(0, Pan2.ar(out, SinOsc.kr(1.5)));
}).add;

//2






// =====================================================================
// SuperCollider Workspace
// =====================================================================


SynthDef("perc_con", {
	| freq = 444, amp = 0.5, modf = 4, atk = 2, dec = 0.4, sus = 0.8, rel = 4, gate |
	var sig, env, out;
	sig = SinOsc.ar(
		freq * SinOsc.ar(
			freq, Pulse.ar(freq/1.7619)) * Pulse.ar(modf));
	sig = GVerb.ar(sig, 100, 1, 0.1, spread:100, earlyreflevel:1.2) * 0.1;
	env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);
	out = sig * env * amp;
	Out.ar(0, out);
}).add
//:
x = Synth("perc_con", [\gate, 1, \modf, 4, \freq, 444])
x.set(\gate, 0)

//:
play{Mix.fill(10, {SinOsc.ar(MouseX.kr(1, 10000) * LFSaw.ar(70) * rrand(0.5, 1.5)).clip2(0.05)})!2}

//:
SynthDef("spoox", {
	| freq = 444, amp = 0.5, atk = 0.001, dec = 0.3, sus = 0.666, rel = 5, gate = 0, pan = 0, cutoff = 16666, thres = 0.666, mix = 0.0, room = 0 |
	var sig, temp, env, out;
	//sig = Mix.fill(10, {SinOsc.ar(MouseX.kr(1, 10000).poll * LFSaw.ar(70) * rrand(0.5, 1.5))});
	sig =
	Mix.fill(10, {
		SinOsc.ar(
			freq * LFSaw.ar(70) * rrand(0.5, 1.5)).clip2(0.1)});
	env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);
	//sig = LPF.ar(sig, cutoff);
	//temp = FFT(LocalBuf(2048), sig);
    //temp = PV_BinScramble(temp, sig, width);
	out = sig * env * amp * 0.666;
	out = Compander.ar(out, out, thres, 1.0, 0.5);
	out = out + FreeVerb.ar(out, mix, room);
	Out.ar(0, Pan2.ar(out, pan))
}).add;

//:
x = Synth("spoox", [\gate, 1]);
x.set(\gate, 0)

//:
//b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

SynthDef("koolaid", {
	| freq = 444, amp = 0.5, atk = 0.1, dec = 0.3, sus = 0.666, rel = 3, gate = 0, pan = 0, cutoff = 6666, thres = 0.666, width = 0.2, mix = 0.0, room = 0 |
	var sig, temp, env, out;
	sig =
	Mix.fill(10, {
		SinOsc.ar(MouseX.kr(1, 10000).poll * LFSaw.ar(70) * rrand(0.5, 1.5))});
	env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);
	sig = LPF.ar(sig, cutoff);
	temp = FFT(LocalBuf(2048), sig);
    temp = PV_BinScramble(temp, sig, width);
	out = env * amp * IFFT(temp) * 0.05;
	out = Compander.ar(out, out, thres, 1.0, 0.5);
	out = out + (FreeVerb.ar(out, mix, room));
	Out.ar(0, Pan2.ar(out, pan))
}).add;
//:

Synth("koolaid", [\gate, 1]);
//:

SynthDef("sine_paradise", {
	| freq = 444, amp = 0.5, pan = 1, atk = 1, dec = 2, sus = 0.7, rel = 3, gate = 0, cutoff = 10000, mod = 0.1, panmod = 50|
	var sig, env, out, temp, sum;
	temp = 0;
	sum = 0;
	env = EnvGen.kr(Env.adsr(atk, dec, sus, rel), gate, doneAction:2);
	10.do(
		temp = SinOsc.ar(freq * [0.5, 0.25, 1, 2, 3].normalizeSum * LFGauss.ar(mod, 0.15), SinOsc.ar(freq*2)) * SinOsc.ar(SinOsc.ar(freq/[2,4], SinOsc.ar(freq/2)));
		temp = Mix(temp);
		sum = sum + temp;
	);
	out = sum * 8 * env * amp;
	Out.ar(0, Pan2.ar(out, pan * SinOsc.kr(panmod).range(-0.8, 0.8)));
	Out.ar(0, Pan2.ar(out, (-1) * pan * SinOsc.kr(panmod).range(0.8, -0.8)));
}).add;

//:
~t1 = Synth("sine_paradise", [\gate, 1]);
~t1.set(\gate, 0);

//:


(
SynthDef("a15", {
    | freq = 440, amp = 0.5, panmod = 4 | 
    var sig, env, out, temp, temp1 , sum, sum1;
    sum = 0; 
    sum1 = 0;
    5.do { temp = SinOsc.ar(freq * ExpRand(0.2, 0.7), mul: Rand(0.05,amp / 5));
        sum = (temp + sum) *
		(LFPulse.kr([Rand(0.5, 7), Rand(0.5, 7)], Rand(0.0, 1.0), Rand(0.0, 1.0), 2)); 
    };
    
    5.do {
        temp1 =  LFPulse.ar(freq * ExpRand(1.0, 7.0), Rand(0.0, 1.0), Rand(0.0, 1.0), mul: Rand(0.05, amp/4));
        sum1 = (temp1 + sum1) *
		(LFPulse.kr([Rand(0.5, 7), Rand(0.5, 7)], Rand(0.0, 1.0), Rand(0.0, 1.0), 2));
    };
    
    env =  EnvGen.ar(Env.adsr(6.66, 0.166, 0.8, 4.33), Line.kr(1, 0, 6.66+0.166+0.2),doneAction:2);
    out = (sum + sum1) * 0.05 * env; 
    out = LPF.ar(out, 1500); 
    out =  BPeakEQ.ar(out, 800, 2, 3); 
    out = out + (FreeVerb.ar(out, 1.0, 0.666)*0.666);
    Out.ar
    (0, Pan2.ar(out* amp, LFNoise0.kr(panmod).range(0.0, 1.0)))} 
).add
);

//:
Synth("a15", [\freq,440])

//:

b = Buffer.alloc(s, 512, 1, { |buf| var ar = Array.fill(10, {654.rand.postln}); buf.sine2Msg(ar,[1,0,1,0,1,1])});//Bellish

//:
b = Buffer.alloc(s, 512, 1, { |buf| var ar = Array.fill(8, {1.0.rand.round(0.001).postln}); buf.sine1Msg(ar)});//El.Guitar

//:
SynthDef("wts_rr", {
    | freq = 440, amp = 0.5, mix = 0.3, room = 100|
    var sig, env, out;
    sig = Shaper.ar(b.bufnum, LFSaw.ar(freq, LFNoise2.kr(1).range(0.0, 1.0)));
    env = Env.perc(0.003, pi/2).kr(doneAction:2);
    out = sig  * amp;
    //out = (out * 0.5) + DelayC.ar(out, 0.2, Rand(0.05, 0.3), 2*pi.reciprocal, out);
	out = FreeVerb2.ar(out, out, mix, room);
    Out.ar(0, out * env); 
}).add;

//:
Synth("wts_rr");

Pbind(
    \instrument,
    \wts_rr,
    \dur, Prand([0.5],inf),
    \scale, Scale.minor,
    \root, -2,
    \degree, Pseq([0, 7, 5, 10, 3, 12, 3, 2, 3, 7, 2, 0],inf),
    \octave, Pseq([Pseq([5], 8), Pseq([6],4)],inf)-1,
    \oct, [2,4,6].choose,
    \susTime, Pwhite(0.1, 0.4,inf),
    \amp, Pwhite(0.5, 0.888, inf)* 0.2,
    \tempo, 100/60,
).play
//:

SynthDef ("varsaw",{
	| freq = 400, amp = 0.5, pan = 0 |
	var env, sig, out, temp, sum;
	temp = 0;
	sum = 0;
	10.do{
		temp =
		Blip.ar(freq * rrand(0.98, 1.02), rrand(6.66, 10.6), SinOsc.ar(freq* 0.5 *rrand(0.95, 1.05)));
		sum = sum + temp;
	};
	env = Env.perc(1, 2).kr(doneAction:2);
	out = sum * env * amp;
	out = BPF.ar(out, XLine.kr(10000, 1000, 0.4));
	Out.ar (0, Pan2.ar(out, pan))
}).add;
//:

Synth("varsaw")
//:
SynthDef("rbass", {
    |freq = 122, amp = 0.5, cf = 5500, dec = 0.45, rel = 0.6, pan|
    var sig, env, out;
    sig = LFSaw.ar(freq) + (Saw.ar(freq * Pulse.kr(freq/4), 0.15) * Saw.ar(freq/2, mul:1) * 0.01);
    env = EnvGen.kr(Env.adsr(0.08, releaseTime:rel), Line.kr(1,0, dec), doneAction:2);
    sig = GVerb.ar(sig, 5, 0.4);
    //sig = FreeVerb.ar(sig, 0.3, 20); //Alternative-GVerb
    out = sig * env * amp * 0.5 ;
    out = LPF.ar(out, 2500);
    out = HPF.ar(out, 150);
    out = MidEQ.ar(out, 300, db: 6);
    out = MidEQ.ar(out, Line.kr(cf + rrand(100, 200), 200, 0.2), 0.2, db: 16);
	out = (out * amp).tanh;
    out = Compander.ar(out, out, 0.05, 1, 0.1, 0.01, 0.01);
    Out.ar(0, Pan2.ar(out, pan));
}).add;
//:

Synth("rbass", [\amp, 1]);
Synth("rbass", [\amp, 2]);
//hard compression
//:

SynthDef("fmsynth", {
	| freq = 444, amp = 0.5 |
	var sig, env, out;
	sig = Mix(
		Saw.ar(
			[freq, freq + 2, freq -3, freq + 3, freq -2, freq -1, freq + 1] ));
	sig = Mix(
		Saw.ar(
			[freq/4, freq/2 + 2, freq/2 -3,
				freq/2 + 3, freq/2 -2, freq/2 -1, freq/2 + 1] * 2));
	sig = sig + Pulse.ar(Line.kr(freq*2, freq, 0.01), mul:6);
	sig = Resonz.ar(sig,
		XLine.kr(10000,100,0.2), //vary filter bandwidth over time
		Line.kr(1,0.05, 0.9)
	);
	
	sig = sig + LPF.ar(WhiteNoise.ar(0.3), 4444);
	env = EnvGen.kr(
		Env.adsr(0.02, 0.1, 0.6, 0.05), Line.kr(1, 0, 0.15), doneAction:0);
	out = sig * env * amp * 0.04;
	out = GVerb.ar(out, 86, revtime: 4.0, ) * Env.perc(0.01, 4).kr(doneAction:2);
	Out.ar(0, Pan2.ar(out));
}).add;

//:
Synth("fmsynth");

//:
Pbind(
	\instrument,
	\fmsynth,
	\dur, 0.25,
	\scale, Scale.ionian,
	\degree, Pseq([0, 7, 5, 12, 11, 0, 2, 5] , inf),
	\octave, [6,5],
	\amp, 1,
	\tempo, 120/60
).play
