

// 1. allocate buffers
(
// fill buffer with test signal
~testSampleBuffer = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// allocate disk output buffer
~testRecBuffer1 =  Buffer.alloc(s, 96000, numChannels: 2);
)

//:

// 2. define synth
(
SynthDef(\testEnvFollow, {
	var sig, env, out;
	sig = PlayBuf.ar(1, ~testSampleBuffer.bufnum, loop: 0, doneAction: 2).abs;
	env = Amplitude.ar(sig, 0.0, 0.2);
	out = [sig, env];
	DiskOut.ar(~testRecBuffer1.bufnum, out);
	Out.ar(0, out);
}).add;
)
//:

// 3. start recording routine
(
fork{
	// create an output file for this buffer, leave it open
	~testRecBuffer1.write("~/Desktop/testRecBuffer1.wav".standardizePath, headerFormat: "wav", sampleFormat: "int24", numFrames: 0, startFrame: 0, leaveOpen: true);

	wait(0.5);
	s.prepareForRecord("~/Desktop/testRecBuffer2.wav".standardizePath, 2);
	wait(0.5);
	s.record(path: "~/Desktop/testRecBuffer2.wav".standardizePath, bus: 0, numChannels: 2, duration: 2.5);
	wait(0.01);

	x = Synth(\testEnvFollow);

	wait(2);
	~testRecBuffer1.close;
	s.stopRecording;
	wait(0.5);

	// read recording from disk
	~testRecBuffer2 = Buffer.read(s, "~/Desktop/testRecBuffer2.wav".standardizePath);

	"done.".postln;
}
);

// 4. plot
(
~testSampleBuffer.plot;
~testRecBuffer1.plot;
~testRecBuffer2.plot;
);
//:

// 5. free buffers
(
~testSampleBuffer.free;
~testRecBuffer1.free;
~testRecBuffer2.free;
)

