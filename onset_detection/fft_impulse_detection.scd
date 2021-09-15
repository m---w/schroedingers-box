//https://doc.sccode.org/Classes/Onsets.html
//: FFT detection tuning
play{
    var sig, chain, onsets, pips, trig, thres;
	
    // Input signal
    sig = SoundIn.ar(0, 1.0);
    chain = FFT(LocalBuf(256), sig);

	thres = MouseX.kr(0.5,1);
	//thres = 1000;
	
	//MouseX is actually the threshold
    onsets = Onsets.kr(chain, thres, \rcomplex);
	
    // output sound
    //pips = SinOsc.ar(2222, mul:EnvGen.kr(Env.perc(0.001, 0.1, 0.2), onsets)) * 5;

	//Trigger
	trig = SendTrig.kr(onsets, 1, value:1);


	//sample
	//pips = WhiteNoise.ar(0.5) * Env.perc(0.000, 0.05).ar(gate: onsets);
	//* Amplitude.ar(sig, 0.01, 4) * 2; //vel detection
	
	/*PlayBufCF.ar(
		2,
		~sound,
		trigger: onsets,
		doneAction:0, n:4) * Amplitude.ar(sig, 0.01, 4) * 2;*/

	//Out.ar(0, Pan2.ar(pips));
	//Out.ar(1, Pan2.ar(sig));
	
}
//:
~sound = Buffer.read(s, "/Users/jsk/Desktop/schroedingers_box/onset_detection/sound1.wav");
/*
tests performed:

High threshold (0.6) & gain sound card (1/4) =======> 
1. table hit is not detected. One has to hit the table quite hard for it to be detected.
2. very low signals are still detected despite the high threshold.
3. scratching is detected as multiple impacts but a lower threshold is needed for them to be detected for sure.
4. loud claps are detected

Low threshold: (0.1) & gain sound card(1/4) ========>
1. table hits are detected. Even the small ones.
2. reacts good to the scratching
3. loud claps are detected more than before
*/

//:
// register to receive this message
a = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval, sp;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	
	fork{
		sp = Synth(\sample_player);
		0.006.wait;
		msg[2].postln;
		fb_trigval = 0;
		if(msg[2] == 1){
			fb_trigval = 1;
			"FBA_agrees".postln;
		};
		if(fb_trigval == 0){sp.set(\gate,0); "FBA_disagrees".postln;}
		
	};
	
	//msg[3].postln;
	
	
},'/tr', s.addr);
//:




//:
//for the first time
// trigger when TBA trigger comes
// wait 6 ms for the fba and if 1 is ok if 0 cancel

b = OSCFunc({ arg msg, time;
	var val, fb_trigval;
    //[time, msg].postln;
	fb_trigval = 0;
	msg.postln;
	//msg[2].postln;
	//if(msg[2] == 1){fb_trigval = msg[3]};
	
	//if(fb_trigval == 1){"FBA_YES".postln};
	//if(fb_trigval == 0){"FBA_NO".postln};
	
},'/tr', s.addr);

//:

SynthDef("sample_player",{
	| gate = 1|
	var sig, env, out;
	sig = PlayBufCF.ar(
		2,
		~sound,
		trigger: gate, n:4);// * Amplitude.ar(sig, 0.01, 4) * 2;
	sig = sig * EnvGen.ar(Env.adsr(0.0, 0.0, 1, 0.0), gate: gate);
	Out.ar(0, Pan2.ar(sig))
}).add
//:




	//:old e.g.
	
// register to receive this message
o = OSCFunc({ arg msg, time;
	var val, tb_trigval, fb_trigval;
    [time, msg].postln;
	tb_trigval = 0;
	fb_trigval = 0;
	msg[2].postln;
	if(msg[2] == 0){tb_trigval = msg[3]};
	if(msg[2] == 1){fb_trigval = msg[3]};
	[tb_trigval, fb_trigval].postln;
	//send trig ==from which algorithm== detection
	if((fb_trigval == 0) && (tb_trigval == 1)){
		"TBA".postln;
	};

	if((fb_trigval == 1) && (tb_trigval == 0)){
		"FBA".postln;
	};
	
	if((fb_trigval == 0) && (tb_trigval == 0)){
		"NONE".postln;
	};
	
	if((tb_trigval == 1) && (fb_trigval == 1)){"MATCH".postln};



	
	
},'/tr', s.addr);



//for the first time
// trigger when TBA trigger comes
// wait 6 ms for the fba and if 1 is ok if 0 cancel






