"Loading OSC Receivers ... ".post;


// OSC Receiver function for synth parameters
~oscSetp = { |dict, key, addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			("OSC incoming:"+addr+val).postln;
		});
		p[dict][key] = val; // update value in dictionary

		// update the corresponding synth
		switch(dict,
			\primary, {
				x[\primary].do{|item|
					if(item.isPlaying, {
						item.set([key, val]);
					});
				};
			},
			\secondary, {
				if(x[\secondary].isPlaying, {
					x[\secondary].set(key, val);
				});
			},
			\outcome, {
				if(x[\outcome].isPlaying, {
					x[\outcome].set(key, val);
				});
			},
			\master, {
				if(x[\master].isPlaying, {
					x[\master].set(key, val);
				});
			},
			\tt, {
				if(x[\tt].isPlaying, {
					x[\tt].set(key, val);
				});
			},
			\od, {
				if(x[\od].isPlaying, {
					x[\od].set(key, val);
				});
			},
			\voicer, {
				if(x[\voicer].isPlaying, {
					x[\voicer].set(key, val);
				});
			}
		);

	}, addr);
};


/*===================== Onset Detection =====================*/


// receive OSC from GUI: create receivers
~oscSetp.(\od, \tbThreshDB, \tbThreshDB);
~oscSetp.(\od, \tbThreshLoDB, \tbThreshLoDB);
//~oscSetOD.(\fbThreshDB);
//~oscSetOD.(\fbRelaxtime);
//~oscSetOD.(\fbFloorDB);
//~oscSetOD.(\fbMingap);
//~oscSetOD.(\fbMedianspan);
~oscSetp.(\od, \velDelay, \velDelay);
~oscSetp.(\od, \tbRefPeriod, \tbRefPeriod);
~oscSetp.(\od, \tbLpf1Freq, \tbLpf1Freq);
~oscSetp.(\od, \tbLpf2Freq, \tbLpf2Freq);
~oscSetp.(\od, \tbHpfFreq, \tbHpfFreq);
//~oscSetOD.(\cancelDel);
~oscSetp.(\od, \inGain1, \inGain1);
~oscSetp.(\od, \inGain2, \inGain2);
~oscSetp.(\od, \inGain3, \inGain3);
~oscSetp.(\od, \inGain4, \inGain4);



/*===================== Sound Parameters =====================*/



// OSC receiver function for global parameters
~oscSetq = { |addr, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			("OSC incoming:"+addr+val).postln;
		});
		q[addr] = val;
	}, addr);
};

// ~oscSetq.(\playbackRand);
~oscSetq.(\breakingThreshold);
~oscSetq.(\secondaryMinDel);
~oscSetq.(\secondaryMaxDel);
~oscSetq.(\secondaryMinCount);
~oscSetq.(\secondaryMaxCount);
~oscSetq.(\secondaryCountCurve);

~oscSetq.(\testOnsetVel);
~oscSetq.(\testOnsetFreq);
~oscSetq.(\testOnsetPosX);
~oscSetq.(\testOnsetPosY);
// ~oscSetq.(\defaultVel);


if(~serverLogic, {
	// Server Logic
	//~oscSetp.(\od, \velMapInMin, \velMapInMin);
	~oscSetp.(\od, \velMapInMax, \velMapInMax);
	~oscSetp.(\od, \velMapOutMin, \velMapOutMin);
	~oscSetp.(\od, \velMapOutMax, \velMapOutMax);
	//~oscSetp.(\od, \velMapCurve, \velMapCurve);

	~oscSetp.(\primary, \velPeakLevel, \velPeakLevel);
	~oscSetp.(\primary, \velPeakMapZeroDB, \velPeakMapZeroDB);

	~oscSetp.(\voicer, \eqMinFreq, \eqMinFreq);
	~oscSetp.(\voicer, \eqMaxFreq, \eqMaxFreq);
}, {
	// SCLang Logic
	~oscSetq.(\velMapInMin);
	~oscSetq.(\velMapInMax);
	~oscSetq.(\velMapOutMin);
	~oscSetq.(\velMapOutMax);
	~oscSetq.(\velMapCurve);

	~oscSetq.(\velPeakLevel);
	~oscSetq.(\velPeakMapZeroDB);

	~oscSetq.(\eqMinFreq);
	~oscSetq.(\eqMaxFreq);
});


/*===================== Synth Parameters =====================*/




// Primary Sound
// ~oscSetp.(\primary, \velUpdateLag, \velUpdateLag);
~oscSetp.(\primary, \eqGain, \eqGain);
~oscSetp.(\primary, \eqRQ, \eqRQ);
~oscSetp.(\primary, \level, \primaryDB);
~oscSetp.(\primary, \velEnvDur, \velEnvDur);
~oscSetp.(\master, \hpfPrimary, \hpfPrimary);

// Secondary Sound
~oscSetp.(\secondary, \upperCutoff, \secondaryCutoff);
~oscSetp.(\secondary, \level, \secondaryDB);

// Outcome Sound
~oscSetp.(\outcome, \level, \outcomeDB);

// Master
~oscSetp.(\master, \primaryLevel, \primaryMasterDB);
~oscSetp.(\master, \secondaryLevel, \secondaryMasterDB);
~oscSetp.(\master, \outcomeLevel, \outcomeMasterDB);
~oscSetp.(\master, \lpf, \masterLPF);
~oscSetp.(\master, \hpf, \masterHPF);
~oscSetp.(\master, \eq, \eq);
~oscSetp.(\master, \masterLevel, \masterLevel);

// Test Tone Generator
~oscSetpTT = {|key| ~oscSetp.(\tt, key, key)}; // shortcut function
~oscSetpTT.(\testFreq);
~oscSetpTT.(\noiseMasterDB);
~oscSetpTT.(\sineMasterDB);
~oscSetpTT.(\toggleSine);
~oscSetpTT.(\toggleNoise);
~oscSetpTT.(\toggle1);
~oscSetpTT.(\toggle2);
~oscSetpTT.(\toggle3);
~oscSetpTT.(\toggle4);
~oscSetpTT.(\flip1);
~oscSetpTT.(\flip2);
~oscSetpTT.(\flip3);
~oscSetpTT.(\flip4);


/*===================== CUSTOM Parameters =====================*/


~oscSetFunc = { |addr, func, printflag=true|
	OSCFunc({|msg, time|
		var val = msg[1];
		if(printflag, {
			("OSC incoming:"+addr+val).postln;
		});
		func.(val, addr);
	}, addr);
};

~oscSetFunc.(\toggleMaster, {|val, addr|
	p.tt[addr] = val;
	if(val==1, {
		if(x[\tt].isPlaying.not, {
			x[\tt] = Synth.new(\tt, p.tt.asKeyValuePairs, addAction: \addToHead).register;
		});
	}, {
		if(x[\tt].isPlaying, {
			x[\tt].free;
		});
	});
});

if(~serverLogic, {
	// Server Logic

	~oscSetFunc.(\panic, {|val, addr|
		// free synths
		//x[\master].free;
		x[\tt].free;
		x[\secondary].free;
		x[\outcome].free;
		x[\voicer].free;
		x[\primary].do{|item| item.free};
		// x[\od].free;
		// set master level to zero
		p.master[\masterLevel] = inf.neg;
		x[\master].set(\masterLevel, p.master[\masterLevel]);
		//q[\od] = 0;
		//q[\output] = 0;
		n.do{|item| item.sendMsg(\bela, \masterLevel, p.master[\masterLevel]) };
		//n.do{|item| item.sendMsg(\bela, \od, q[\od]) };
		//n.do{|item| item.sendMsg(\bela, \output, q[\output]) };
	});

	~oscSetp.(\voicer, \slMaxPlaybackRate, \slMaxPlaybackRate);

	~oscSetFunc.(\slMaxRatio, {|val, addr|
		q[\slMaxRatio] = val;
		p[\od][\slMaxRatioDB] = q[\slMaxRatio].ampdb;
		if(x[\od].isPlaying, {
			x[\od].set(\slMaxRatioDB, p[\od][\slMaxRatioDB]);
		});
	});


}, {
	// SCLang Logic

	~oscSetFunc.(\panic, {|val, addr|
		// free synths
		v.panic;
		v.free;
		//x[\master].free;
		x[\tt].free;
		x[\secondary].free;
		x[\outcome].free;
		// x[\od].free;
		// set master level to zero
		p.master[\masterLevel] = inf.neg;
		x[\master].set(\masterLevel, p.master[\masterLevel]);
		//q[\od] = 0;
		//q[\output] = 0;
		n.do{|item| item.sendMsg(\bela, \masterLevel, p.master[\masterLevel]) };
		//n.do{|item| item.sendMsg(\bela, \od, q[\od]) };
		//n.do{|item| item.sendMsg(\bela, \output, q[\output]) };
	});

	~oscSetFunc.(\slMaxPlaybackRate, {|val, addr|
		q[\slMaxPlaybackRate] = val;
		q[\slMinPlaybackRate] = val.reciprocal;
	});

	~oscSetFunc.(\slMaxRatio, {|val, addr|
		q[\slMaxRatio] = val;
		q[\slMinRatio] = val.reciprocal;
	});

	~oscSetFunc.(\triggerOnset, {|val, addr|
		~lastvoice = ~newPrimarySoundTest.(); // trigger new primary sound
		~maybeNewSecondarySound.(); // maybe trigger new secondary sound
	});

	~oscSetFunc.(\toggleOnsets, {|val, addr|
		q[\toggleOnsets] = val;
		if(val==1, {
			Tdef(\outOnset, { loop{
				q[\testOnsetFreq].reciprocal.wait;
				// set position
				~lastvoice = ~newPrimarySoundTest.(); // trigger new primary sound
				~maybeNewSecondarySound.(); // maybe trigger new secondary sound
			}}).play;
		},{
			Tdef(\outOnset).stop;
		});
	});


});



~oscSetFunc.(\record, {|val, addr|
	if(
		val==1,
		{if(~testRecSynth.isPlaying, {}, {
			q.testRecPath = (~path+/+"rec/rec_"++Date.getDate.format("%Y-%m-%d_%H-%M-%S")++".wav").standardizePath;
			q.testRecBuf.write(q.testRecPath, "WAV", "int24", 0, 0, true); // create file, leave open
			~testRecSynth = Synth.new(\recorder, [\buf, q.testRecBuf.bufnum, \primaryBus, p.primary[\busnum]]).register; // record
			("Recording started ("++q.testRecPath++")").postln;
		};);},
		{
			~testRecSynth.free;
			q.testRecBuf.close;
			("Recording stopped ("++q.testRecPath++")").postln;
		}
	);
});

/*
~oscSetFunc.(\od, {|val, addr|
	q[\od] = val;
	if(
		val==1,
		{if(x[\od].isPlaying, {}, {
			x[\od] = Synth.new(\od, p.od.asKeyValuePairs, addAction: \addToHead).register; // start onset detection synth
		};);},
		{
			x[\od].free;
		}
	);
});

~oscSetFunc.(\output, {|val, addr|
	q[\output] = val;
	if(
		val==1,
		{if(x[\master].isPlaying, {}, {
			x[\master] = Synth.new(\master, p.master.asKeyValuePairs, addAction: \addToTail).register; // start master synth
		};);},
		{
			x[\master].free;
		}
	);
});
*/

"done.".postln;