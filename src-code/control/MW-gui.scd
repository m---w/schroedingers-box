/*
Schroedinger's Box
SuperCollider Control Patch for Bela
2021 Jason Svoronos-Kanavas, Marian Weger
*/

(
Window.closeAll;

//n = NetAddr("192.168.185.50", 57120);
n = NetAddr("bela.local", 57120); // set bela remote address


// OSC receiver to get messages from Bela
OSCFunc({|msg, time|
	var key = msg[1];
	("OSC incoming:"+msg).postln;
	switch(key,
		\booted, {
			~gui.resend(); // let GUI resend parameters
		},
	);
},'/bela');


// parameter default values
e = (); // create empty dictionary

// TBOD
e.tbThreshDB = 120.0.neg; // TBOD threshold in dB
e.tbRefPeriod = 0.05;// specifies a minimum gap (in seconds) between subsequent onset detections
e.lpf1Freq = 25.0; // frequency of 1st low-pass filter in Hz (TBOD)
e.lpf2Freq = 25.0; // frequency of 2nd low-pass filter in Hz (TBOD)
e.hpfFreq = 4000.0; // frequency of high-pass filter in Hz  (TBOD)
e.cancelDel = 1.0; // Delay between TBOD trigger and cancel message, in FFT frames.

// FBOD
e.fbThreshDB = -22.0; // FBOD threshold in dB
e.relaxtime = 1.0; // specifies the time (in seconds) for the normalisation to "forget" about a recent onset. If you find too much re-triggering (e.g. as a note dies away unevenly) then you might wish to increase this value.
e.floorDB = 20.0.neg; // is a lower limit, connected to the idea of how quiet the sound is expected to get without becoming indistinguishable from noise. For some cleanly-recorded classical music with wide dynamic variations, I found it helpful to go down as far as 0.000001.
e.mingap = 40; // specifies a minimum gap (in FFT frames) between onset detections, a brute-force way to prevent too many doubled detections.
e.medianspan = 11; // specifies the size (in FFT frames) of the median window used for smoothing the detection function before triggering.

// Velocity detection
e.veldelay = 0.006; // delay between FBOD trigger and reporting of velocity. Velocity will be the maximum in this time period.

// Master
e.mainDB = inf.neg; // main volume in dB
e.catDB = 60.neg; // cat volume in dB

// Experiment
e.participantID = 0; // participant ID
e.preset = 0; // sound preset



// GUI function definition
~schroedingersGUI = {|n, e|

	// settings of all the sliders in the GUI
	// They will appear in this order in the GUI
	var sliderList = [
		// oscname min max warp step units label factor name
		// 0       1   2   3    4    5     6     7      8

		// TBOD
		['/tbod/threshDB', -180, 0.0, \lin, 1.0, "dB", "TBOD threshold", 1.0, \tbThreshDB],
		['/tbod/hpfFreq', 80.0, 8000.0, \exp, 1.0, "Hz", "HPF cutoff", 1.0, \hpfFreq],
		['/tbod/lpf1Freq', 1.0, 120.0, \lin, 1.0, "Hz", "LPF 1 cutoff", 1.0, \lpf1Freq],
		['/tbod/lpf2Freq', 1.0, 120.0, \lin, 1.0, "Hz", "LPF 2 cutoff", 1.0, \lpf2Freq],
		['/tbod/refPeriod', 0.1, 500.0, \exp, 1.0, "ms", "TBOD refractory period", 1.0e-3, \tbRefPeriod],
		['/fac/cancelDel', 0.0, 32.0, \lin, 1.0, "FFT frames", "False Alarm Cancellation delay", 1.0, \cancelDel],

		// FBOD
		['/fbod/threshDB', -40, 40.0, \lin, 1.0, "dB", "FBOD threshold", 1.0, \fbThreshDB],
		['/fbod/relaxtime', 0.1, 10.0, \exp, 0.1, "s", "Relax Time", 1.0, \relaxtime],
		['/fbod/floorDB', 140.0.neg, 0.0, \exp, 1.0, "dB", "Floor", 1.0, \floorDB],
		['/fbod/mingap', 0.0, 100.0, \lin, 1.0, "FFT frames", "MinGap", 1.0, \mingap],
		['/fbod/medianspan', 0.0, 30.0, \lin, 1.0, "FFT frames", "MedianSpan", 1.0, \medianspan],

		// Velocity Detection
		['/vel/delay', 0.1, 50.0, \exp, 0.1, "ms", "Velocity Delay", 1.0e-3, \veldelay],

		// Master
		['/master/cat', -60.0, 10.0, \lin, 0.1, "dB", "Cat Volume", 1.0, \catDB],
		['/master/main', -60.0, 10.0, \lin, 0.1, "dB", "Master Volume", 1.0, \mainDB],

	];

	// convert to dictionary, to address them by name
	var sliderDict = ().putPairs([sliderList.flop.last,sliderList].flop.flatten);

	// slider creation function
	var makeSlider = { |item|
		EZSlider(elements[\w].view, 900@25, "  "++item[6]++"  ",
			ControlSpec(minval: item[1], maxval: item[2], warp: item[3], step: item[4], default: e[item[8]]/item[7], units: item[5]),
			labelWidth: 280, unitWidth: 100, initVal: e[item[8]]/item[7], numberWidth: 60, layout: \horz, initAction: true)
		.setColors(Color.grey, Color.white)
		.font_(Font("Helvetica", 14))
		.action_({ |ez|
			e[item[8]] = ez.value*item[7]; // update value in settings dictionary
			n.sendMsg(item[0], e[item[8]]); // send updated value via OSC
			(item[8]++":"+e[item[8]]).postln; // print message
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
		StaticText(elements[\w].view, 900@26)
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
	elements[\w] = Window("Schroedinger's GUI", Rect(400,400,910,700))
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
	makeSliders.(elements[\params], sliderDict, [\tbThreshDB, \hpfFreq, \lpf1Freq, \lpf2Freq, \tbRefPeriod, \cancelDel]);
	newline.();

	heading.("FBOD");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\fbThreshDB, \relaxtime, \floorDB, \mingap, \medianspan]);
	newline.();

	heading.("Velocity detection");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\veldelay]);
	newline.();

	heading.("Master");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\catDB, \mainDB]);
	newline.();

	heading.("Sound Selection");
	newline.();
	elements[\samplePicker] = EZNumber(elements[\w].view, 900@25, "  Preset  ",
		ControlSpec(minval: 0, maxval: 99, step: 1, default: e[\preset]),
		labelWidth: 280, unitWidth: 0, initVal: e[\preset], numberWidth: 60, layout: \horz, initAction: true)
	.setColors(Color.grey, Color.white)
	.font_(Font("Helvetica", 14))
	.action_({ |ez|
		e[\preset] = ez.value.asInteger; // update value in settings dictionary
		n.sendMsg('/soundpick/2', \sam_num, e[\preset]); // send updated value via OSC
		("samplePicker:"+e[\preset]).postln; // print message
	});

	heading.("Experiment");
	newline.();
	elements[\participantID] = EZNumber(elements[\w].view, 900@25, "  Participant ID  ",
		ControlSpec(minval: 0, maxval: 99, step: 1, default: e[\participantID]),
		labelWidth: 280, unitWidth: 0, initVal: e[\preset], numberWidth: 60, layout: \horz, initAction: true)
	.setColors(Color.grey, Color.white)
	.font_(Font("Helvetica", 14))
	.action_({ |ez|
		e[\participantID] = ez.value.asInteger; // update value in settings dictionary
		n.sendMsg('/experiment', \participantID, e[\participantID]); // send updated value via OSC (DOES BELA NEED TO KNOW IT?)
		// DO SOMETHING HERE!
		("Participant ID:"+e[\participantID]).postln; // print message
	});

	// update function (call from outside to update GUI to current parameter values)
	elements[\upd] = {
		elements[\params].keysValuesDo{|key,item|
			elements.params[key].value = e[key]/sliderDict[key][7];
		};
		elements[\samplePicker].value = e[\preset];
		"GUI updated"; // return message
	};

	// resend function (call from outside to resend all values)
	elements[\resend] = {
		elements[\params].keysValuesDo{|key,item|
			elements.params[key].doAction;
		};
		elements[\samplePicker].doAction;
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


)