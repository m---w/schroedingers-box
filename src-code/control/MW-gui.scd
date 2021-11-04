/*
Schroedinger's Box
SuperCollider Control Patch for Bela
2021 Jason Svoronos-Kanavas, Marian Weger
*/
([[1,2],[3,4]]).flop.last

(
Window.closeAll;

//n = NetAddr("192.168.184.21", 57120);
n = NetAddr("bela.local", 57120); // set bela remote address

// parameter default values
e = ();
e.tbaThreshDB = -20.0; // tba trhreshold in dB
e.fbaThreshDB = -20.0; // fba threshold in dB
e.mainDB = inf.neg; // main volume in dB
e.catDB = 60.neg; // cat volume in dB
e.preset = 0; // sound preset


// GUI function definition
~schroedingersGUI = {|n, e|

	// settings of all the sliders in the GUI
	var sliderList = [
		// oscname min max warp step units label factor name
		// 0       1   2   3    4    5     6     7      8
		['/thres/tba_thres_db', -60, 0, \lin, 0.0, "dB", "TBOD threshold", 1, \tbaThreshDB],
		['/thres/fba_thres_db', -60, 0, \lin, 0.0, "dB", "FBOD threshold", 1, \fbaThreshDB],
		['/master/main', -60, 10, \lin, 0.0, "dB", "Master Volume", 1, \mainDB],
		['/master/cat', -60, 10, \lin, 0.0, "dB", "Cat Volume", 1, \catDB],
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
	elements[\w] = Window("Schroedinger's GUI", Rect(400,400,910,600))
	.alwaysOnTop_(true)
	.visible_(true)
	.front;

	// View
	elements[\v] = elements[\w].view
	.decorator_(FlowLayout(elements[\w].view.bounds))
	.background_(Color(0.1, 0.1, 0.1))
	.decorator.gap_(2@2);


	// GUI SETUP

	heading.("Onset Detection");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\tbaThreshDB, \fbaThreshDB]);
	newline.();

	heading.("Sound");
	newline.();
	makeSliders.(elements[\params], sliderDict, [\mainDB, \catDB]);
	newline.();

	heading.("Sample Picker");
	newline.();
	elements[\samplePicker] = EZNumber(elements[\w].view, 900@25, "  preset  ",
		ControlSpec(minval: 0, maxval: 99, step: 1, default: e[\preset]),
		labelWidth: 280, unitWidth: 0, initVal: e[\preset], numberWidth: 60, layout: \horz, initAction: true)
	.setColors(Color.grey, Color.white)
	.font_(Font("Helvetica", 14))
	.action_({ |ez|
		e[\preset] = ez.value.asInteger; // update value in settings dictionary
		n.sendMsg('/soundpick/2', \sam_num, e[\preset]); // send updated value via OSC
		("samplePicker:"+e[\preset]).postln; // print message
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

// if parameters are updated within the settings dictionary e, then call ~gui.upd.() to update the gui
// to resend the current gui state, call ~gui.resend.()


)