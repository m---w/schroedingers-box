/*
Schroedinger's Box
SuperCollider Control Patch for Bela
2021 Jason Svoronos-Kanavas, Marian Weger
*/
//Ⓢⓒⓗⓡⓞⓔⓓⓘⓝⓖⓔⓡⓢ Ⓑⓞⓧ

(
~localMode = false; // SET CORRECT MODE HERE! (false=Bela, true=local)

if(~localMode, {
	o = NetAddr("localhost", 57120); // set local address
}, {
	o = NetAddr("bela.local", 57120); // set bela remote address
});

Window.closeAll;


// OSC receiver to get messages from Bela
OSCFunc({|msg, time|
	var key = msg[1];
	var val = msg[2];
	("OSC incoming:"+msg).postln;
	switch(key,
		\booted, {
			~gui.resend(); // let GUI resend parameters
		},
		\mainDB, {
			e.mainDB = val; // master volume (GUI) via each sound config file in Bela
			{~gui.upd.()}.defer; // then update GUI
		},
		\catDB, {
			e.catDB = val; // Cat volume (GUI) value
			{~gui.upd.()}.defer;
		},
	);
},'/bela');


// parameter default values
e = (); // create empty dictionary

// TBOD
e.tbThreshDB = 120.0.neg; // TBOD threshold in dB
e.tbRefPeriod = 0.05;// specifies a minimum gap (in seconds) between subsequent onset detections
e.tbLpf1Freq = 25.0; // frequency of 1st low-pass filter in Hz (TBOD)
e.tbLpf2Freq = 25.0; // frequency of 2nd low-pass filter in Hz (TBOD)
e.tbHpfFreq = 4000.0; // frequency of high-pass filter in Hz  (TBOD)
e.cancelDel = 1.0; // Delay between TBOD trigger and cancel message, in FFT frames.

// FBOD
e.fbThreshDB = -22.0; // FBOD threshold in dB
e.fbRelaxtime = 1.0; // specifies the time (in seconds) for the normalisation to "forget" about a recent onset. If you find too much re-triggering (e.g. as a note dies away unevenly) then you might wish to increase this value.
e.fbFloorDB = 20.0.neg; // is a lower limit, connected to the idea of how quiet the sound is expected to get without becoming indistinguishable from noise. For some cleanly-recorded classical music with wide dynamic variations, I found it helpful to go down as far as 0.000001.
e.fbMingap = 40; // specifies a minimum gap (in FFT frames) between onset detections, a brute-force way to prevent too many doubled detections.
e.fbMedianspan = 11; // specifies the size (in FFT frames) of the median window used for smoothing the detection function before triggering.

// Velocity detection
e.velDelay = 0.006; // delay between FBOD trigger and reporting of velocity. Velocity will be the maximum in this time period.
e.defaultVel = 0.01; // default velocity
e.velUpdateLag = 0.001;

// Master
e.mainDB = inf.neg; // main volume in dB
e.catDB = inf.neg; // cat volume in dB

e.mainGlobalDB = inf.neg; // main volume in dB
e.catGlobalDB = inf.neg; // cat volume in dB

// Experiment
e.participantID = 0; // participant ID
e.preset = 0; // sound preset

// Test Tone Generator
e.sineMasterDB = 80.0.neg;
e.noiseMasterDB = 80.0.neg;
e.testFreq = 400.0;
e.toggleMaster = 0;
e.toggle1 = 0;
e.toggle2 = 0;
e.toggle3 = 0;
e.toggle4 = 0;
e.flip1 = 0;
e.flip2 = 0;
e.flip3 = 0;
e.flip4 = 0;

e.combFiltMinFreq = 20.0;
e.combFiltMaxFreq = 20000.0;
e.combFiltDryWet = 0.0;

e.playbackRand = 0.1; // percent rate randomization

e.breakingThreshold = 0.1;

e.addMinDel = 0.5;
e.addMaxDel = 1.0;
e.addCutoff = 1000.0;


// GUI function definition
~schroedingersGUI = {|n, e|

	// settings of all the sliders in the GUI
	// They will appear in this order in the GUI
	var sliderList = [
		// min max warp step units label factor name
		// 0   1   2    3    4     5     6      7

		// TBOD
		[-180, 0.0, \lin, 1.0, "dB", "TBOD threshold", 1.0, \tbThreshDB],
		[80.0, 8000.0, \exp, 1.0, "Hz", "HPF cutoff", 1.0, \tbHpfFreq],
		[1.0, 120.0, \lin, 1.0, "Hz", "LPF 1 cutoff", 1.0, \tbLpf1Freq],
		[1.0, 120.0, \lin, 1.0, "Hz", "LPF 2 cutoff", 1.0, \tbLpf2Freq],
		[0.1, 500.0, \exp, 1.0, "ms", "TBOD refractory period", 1.0e-3, \tbRefPeriod],
		[0.0, 32.0, \lin, 1.0, "FFT frames", "False Alarm Cancellation delay", 1.0, \cancelDel],

		// FBOD
		[-40, 40.0, \lin, 1.0, "dB", "FBOD threshold", 1.0, \fbThreshDB],
		[0.1, 10.0, \exp, 0.1, "s", "Relax Time", 1.0, \fbRelaxtime],
		[140.0.neg, 0.0, \lin, 1.0, "dB", "Floor", 1.0, \fbFloorDB],
		[0.0, 100.0, \lin, 1.0, "FFT frames", "MinGap", 1.0, \fbMingap],
		[0.0, 30.0, \lin, 1.0, "FFT frames", "MedianSpan", 1.0, \fbMedianspan],

		// Velocity Detection
		[0.1, 50.0, \exp, 0.1, "ms", "Velocity Delay", 1.0e-3, \velDelay],
		[0.1, 50.0, \exp, 0.1, "ms", "Velocity Update Lag", 1.0e-3, \velUpdateLag],
		[0.0001, 1.0, \exp, 0.0, "", "Default Velocity", 1.0, \defaultVel],

		// Levels (current preset)
		[-60.0, 30.0, \lin, 0.1, "dB", "Secondary sound level", 1.0, \catDB],
		[-60.0, 30.0, \lin, 0.1, "dB", "Primary sound level", 1.0, \mainDB],

		// Master Levels
		[-60.0, 30.0, \lin, 0.1, "dB", "Global secondary sound level", 1.0, \catGlobalDB],
		[-60.0, 30.0, \lin, 0.1, "dB", "Global primary sound level", 1.0, \mainGlobalDB],

		// Test Tone Generator
		[-80.0, 0.0, \lin, 0.1, "dB", "Noise Volume", 1.0, \noiseMasterDB],
		[-80.0, 0.0, \lin, 0.1, "dB", "Sine Volume", 1.0, \sineMasterDB],
		[20.0, 20000.0, \exp, 1.0, "Hz", "Sine Frequency", 1.0, \testFreq],

		// Sound
		[20.0, 20000.0, \exp, 1.0, "Hz", "Comb-filter Min Frequency", 1.0, \combFiltMinFreq],
		[20.0, 20000.0, \exp, 1.0, "Hz", "Comb-filter Max Frequency", 1.0, \combFiltMaxFreq],
		[-1.0, 1.0, \lin, 0.0, "", "Comb Filter Dry/Wet", 1.0, \combFiltDryWet],
		[0.0, 10.0, \lin, 0.1, "%", "Playback Rate Randomization", 1.0e-2, \playbackRand],
		[0.001, 1.0, \exp, 0.0, "", "Breaking Threshold", 1.0, \breakingThreshold],
		[0.0, 5.0, \lin, 0.1, "s", "Min Delay for Secondary Sound", 1.0, \addMinDel],
		[0.0, 5.0, \lin, 0.1, "s", "Max Delay for Secondary Sound", 1.0, \addMaxDel],
		[20.0, 20000.0, \exp, 1.0, "Hz", "Secondary Sound Upper Cutoff", 1.0, \addCutoff],


	];

	// convert to dictionary, to address them by name
	var sliderDict = ().putPairs([sliderList.flop.last,sliderList].flop.flatten);

	// slider creation function
	var makeSlider = { |item|
		EZSlider(elements[\w].view, 900@20, "  "++item[5]++"  ",
			ControlSpec(minval: item[0], maxval: item[1], warp: item[2], step: item[3], default: e[item[7]]/item[6], units: item[4]),
			labelWidth: 280, unitWidth: 100, initVal: e[item[7]]/item[6], numberWidth: 60, layout: \horz, initAction: true)
		.setColors(Color.grey, Color.white)
		.font_(Font("Helvetica", 12))
		.action_({ |ez|
			e[item[7]] = ez.value*item[6]; // update value in settings dictionary
			o.sendMsg('/'++item[7], e[item[7]]); // send updated value via OSC
			(item[7]++":"+e[item[7]]).postln; // print message
		});
	};

	// function that creates sliders called by their name
	var makeSliders = {|target, dict, keys|
		keys.asArray.do{|key|
			target[key] = makeSlider.(dict[key]);
		};
	};

	// function to create a heading
	var heading = { |text|
		StaticText(elements[\w].view, 900@24)
		.string_(text++":")
		.font_(Font("Helvetica", 18))
		.stringColor_(Color.white)
		;
	};

	// dictionary that is returned by the GUI function
	var elements = ();

	// function to create a newline
	var newline = { elements[\v].nextLine };

	// dictionary to access individual sliders from outside
	elements[\params] = ();

	// Window
	elements[\w] = Window("Schroedinger's GUI", Rect(400,400,910,900), scroll: true)
	.alwaysOnTop_(true)
	.visible_(true)
	.front;

	// View
	elements[\v] = elements[\w].view
	.decorator_(FlowLayout(elements[\w].view.bounds))
	.background_(Color(0.1, 0.1, 0.1))
	.decorator.gap_(2@2);


	// GUI SETUP

	heading.("TBOD");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\tbThreshDB, \tbHpfFreq, \tbLpf1Freq, \tbLpf2Freq, \tbRefPeriod, \cancelDel]);
	newline.();

	heading.("FBOD");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\fbThreshDB, \fbRelaxtime, \fbFloorDB, \fbMingap, \fbMedianspan]);
	newline.();

	heading.("Velocity detection");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\velDelay, \velUpdateLag, \defaultVel]);
	newline.();

	heading.("Levels (current preset)");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\catDB, \mainDB]);
	newline.();

	heading.("Master Levels");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\catGlobalDB, \mainGlobalDB]);
	newline.();

	heading.("Sound");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\combFiltMinFreq, \combFiltMaxFreq, \combFiltDryWet, \playbackRand, \breakingThreshold, \addMinDel, \addMaxDel, \addCutoff]);
	newline.();

	heading.("Test signal generator");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\noiseMasterDB, \sineMasterDB, \testFreq]);
	newline.();¸

	elements[\toggleMaster] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["TestTone", Color.white, Color.gray], ["TestTone", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggleMaster] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggleMaster', e[\toggleMaster].asFloat); // send updated value via OSC
		("Test Tone State:"+e[\toggleMaster]).postln; // print message
	});
	elements[\toggleSine] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Sine", Color.white, Color.gray], ["Sine", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggleSine] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggleSine', e[\toggleSine].asFloat); // send updated value via OSC
		("Sine State:"+e[\toggleSine]).postln; // print message
	});
	elements[\toggleNoise] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Noise", Color.white, Color.gray], ["Noise", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggleNoise] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggleNoise', e[\toggleNoise].asFloat); // send updated value via OSC
		("Noise State:"+e[\toggleNoise]).postln; // print message
	});

	elements[\toggle1] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Ch.1", Color.white, Color.gray], ["Ch.1", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggle1] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggle1', e[\toggle1].asFloat); // send updated value via OSC
		("Test Tone State Ch.1:"+e[\toggle1]).postln; // print message
	});
	elements[\toggle2] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Ch.2", Color.white, Color.gray], ["Ch.2", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggle2] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggle2', e[\toggle2].asFloat); // send updated value via OSC
		("Test Tone State Ch.2:"+e[\toggle2]).postln; // print message
	});
	elements[\toggle3] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Ch.3", Color.white, Color.gray], ["Ch.3", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggle3] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggle3', e[\toggle3].asFloat); // send updated value via OSC
		("Test Tone State Ch.3:"+e[\toggle3]).postln; // print message
	});
	elements[\toggle4] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Ch.4", Color.white, Color.gray], ["Ch.4", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\toggle4] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/toggle4', e[\toggle4].asFloat); // send updated value via OSC
		("Test Tone State Ch.4:"+e[\toggle4]).postln; // print message
	});
	elements[\flip1] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Flip Ch.1", Color.white, Color.gray], ["Flip Ch.1", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\flip1] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/flip1', e[\flip1].asFloat); // send updated value via OSC
		("Flip Ch.1:"+e[\flip1]).postln; // print message
	});
	elements[\flip2] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Flip Ch.2", Color.white, Color.gray], ["Flip Ch.2", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\flip2] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/flip2', e[\flip2].asFloat); // send updated value via OSC
		("Flip Ch.2:"+e[\flip2]).postln; // print message
	});
	elements[\flip3] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Flip Ch.3", Color.white, Color.gray], ["Flip Ch.3", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\flip3] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/flip3', e[\flip3].asFloat); // send updated value via OSC
		("Flip Ch.3:"+e[\flip3]).postln; // print message
	});
	elements[\flip4] = Button(elements[\w], Rect(0,0,120,30))
	.states_([["Flip Ch.4", Color.white, Color.gray], ["Flip Ch.4", Color.gray, Color.green]])
	.action_({|obj|
		var val = obj.value;
		e[\flip4] = val.asInteger; // update value in settings dictionary
		o.sendMsg('/flip4', e[\flip4].asFloat); // send updated value via OSC
		("Flip Ch.4:"+e[\flip4]).postln; // print message
	});
	newline.();

	heading.("Participant and Sound Selection");
	newline.();
	elements[\preset] = EZNumber(elements[\w].view, 900@25, "  Preset  ",
		ControlSpec(minval: -1, maxval: 99, step: 1, default: e[\preset]),
		labelWidth: 280, unitWidth: 0, initVal: e[\preset], numberWidth: 60, layout: \horz, initAction: true)
	.setColors(Color.grey, Color.white)
	.font_(Font("Helvetica", 14))
	.action_({ |ez|
		e[\preset] = ez.value.asInteger; // update value in settings dictionary
		o.sendMsg('/preset', e[\preset]); // send updated value via OSC
		("Preset:"+e[\preset]).postln; // print message
	});

	newline.();
	elements[\participantID] = EZNumber(elements[\w].view, 900@25, "  Participant ID  ",
		ControlSpec(minval: 0, maxval: 99, step: 1, default: e[\participantID]),
		labelWidth: 280, unitWidth: 0, initVal: e[\preset], numberWidth: 60, layout: \horz, initAction: true)
	.setColors(Color.grey, Color.white)
	.font_(Font("Helvetica", 14))
	.action_({ |ez|
		e[\participantID] = ez.value.asInteger; // update value in settings dictionary
		o.sendMsg('/participantID', e[\participantID]); // send updated value via OSC
		~sample = -1; // init sample number
		elements[\preset].valueAction_(~sample);
		("Participant ID:"+e[\participantID]).postln; // print message
	});

	// update function (call from outside to update GUI to current parameter values)
	elements[\upd] = {
		elements[\params].keysValuesDo{|key,item|
			elements.params[key].value = e[key]/sliderDict[key][6];
		};
		elements[\preset].value = e[\preset];
		elements[\participantID].value = e[\participantID];
		elements[\toggleMaster].value = e[\toggleMaster];
		elements[\toggleNoise].value = e[\toggleNoise];
		elements[\toggleSine].value = e[\toggleSine];
		elements[\toggle1].value = e[\toggle1];
		elements[\toggle2].value = e[\toggle2];
		elements[\toggle3].value = e[\toggle3];
		elements[\toggle4].value = e[\toggle4];
		elements[\flip1].value = e[[\flip1]];
		elements[\flip2].value = e[\flip2];
		elements[\flip3].value = e[\flip3];
		elements[\flip4].value = e[\flip4];
		"GUI updated"; // return message
	};

	// resend function (call from outside to resend all values)
	elements[\resend] = {
		elements[\params].keysValuesDo{|key,item|
			elements.params[key].doAction;
		};
		elements[\preset].doAction;
		elements[\participantID].doAction;
		elements[\toggleMaster].doAction;
		elements[\toggleNoise].doAction;
		elements[\toggleSine].doAction;
		elements[\toggle1].doAction;
		elements[\toggle2].doAction;
		elements[\toggle3].doAction;
		elements[\toggle4].doAction;
		elements[\flip1].doAction;
		elements[\flip2].doAction;
		elements[\flip3].doAction;
		elements[\flip4].doAction;
		"settings sent"; // return message
	};

	// return gui dictionary
	elements;

};


// START GUI
~gui = ~schroedingersGUI.(n, e);

~gui.resend.();

// if parameters are updated within the settings dictionary e, then call ~gui.upd.() to update the gui
// to resend the current gui state, call ~gui.resend.()


//=============================================================
//load big red button config
(Document.current.dir +/+ "/big-red-button.scd").asString.standardizePath.load;
//=============================================================

)