

// based on measurement "rec_2022-01-06_11-23-54.wav".

~sampleRate = 48000;

// roundtrip latency: constant 256 samples
~roundTripLatency = 256*1000/~sampleRate; // -> 5.3333333333333 ms

// onset detection latency: variable
~onsetDetectionLatencies = [48, 56, 95, 73, 80, 107, 91];
~minMaxOnsetDetectionLatency = [~onsetDetectionLatencies.minItem, ~onsetDetectionLatencies.maxItem]*1000/~sampleRate; // -> [ 1.0, 2.2291666666667 ] ms




~totalLatency = (~minMaxOnsetDetectionLatency + ~roundTripLatency); // -> [ 6.3333333333333, 7.5625 ] ms





