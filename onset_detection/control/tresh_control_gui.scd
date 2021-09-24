//Schroendinger's box control

(
Window.closeAll;
s.waitForBoot({

	var w, tba_threshi, tba_threslo, fba_thres;
	
	~n = NetAddr("192.168.184.21", 57120);

    w = Window("Schroedinger's box control").alwaysOnTop_(true);//Setting Up the Window
    w.bounds_(Rect(900, 500, 300, 200));
    w.view.background_(Color.gray);
    w.front;

    //menu = PopUpMenu(w, Rect(10, 10, 90, 20))//Waveforms__EvaluationAtFuncs0--Carrier
    //.items_(["Sine", "Saw" , "SawTooth" , "Pulse"]);

    //menu1 = PopUpMenu(w, Rect(10, 60, 90, 20))//Waveforms__EvaluationAtFuncs1--Modulator
    //.items_(["Sine", "Saw" , "SawTooth" , "Pulse"]);

    tba_threshi = 0;
	tba_threslo = 0;

	fba_thres = 0;

	~text = Array.fill( 5, {StaticText (w , Rect (200, 175, 100, 20))
        .string_("TBA_thres_high")
        .font_(Font("Times New Roman", 15))
        .align_(\center)
        .background_(Color.gray)
        .stringColor_(Color.red)});
    ~text[0].bounds_(Rect(8, 0, 120, 20)).string_("TBA");
    ~text[1].bounds_(Rect(-10, 25, 100, 10)).string_("hi-th.").stringColor_(Color.white);
	~text[2].bounds_(Rect(80, 25, 50, 10)).string_("lo-th.").stringColor_(Color.white);
	~text[3].bounds_(Rect(180, 0, 120, 20)).string_("FBA");
	~text[4].bounds_(Rect(180, 20, 120, 20)).string_("thres.").stringColor_(Color.white);
    
	
    //knobs
    k = Array.fill(3, {Knob(w, Rect(0,100, 100, 50))});
	k[0].bounds_(Rect(0, 45, 88, 45)).value_(0.0);
    k[1].bounds_(Rect(60, 45, 88, 45)).value_(0.0);
    k[2].bounds_(Rect(200, 45, 88, 45)).value_(0.0);

	
	k[0].action_({
		|obj|
		var val;
		val = obj.value.linlin(0.0, 1.0, 0.0, 1e-3);
		val.postln;
				//q.set only local no osc
		//q.set(\tba_hi, val);
				//sendMsg to bela
		~n.sendMsg('/thres/tba_hi', val);
		~nb_tba_hi.value_(val);
	});

	k[1].action_({
		|obj|
		var val;
		val = obj.value.linlin(0.0, 1.0, 0.0, 0.001);
		val.postln;
		//q.set only local no osc
		//q.set(\tba_lo, val);
		//sendMsg to bela
		~n.sendMsg('/thres/tba_lo', val);
		~nb_tba_lo.value_(val.value);
	});

	k[2].action_({
		|obj|
		var val;
		val = obj.value.linlin(0.0, 1.0, 0.0, 2.0);
		val.postln;
		//q.set only local no osc
		//q.set(\fba_thres, val);
		//sendMsg to bela
		~n.sendMsg('/thres/fba_thres', val);
        ~nb_fba.value_(val.value);//GoesToNumberBox
	});
	
	~nb_tba_hi = NumberBox(w, Rect(20, 105, 50, 20))
    .value_(0.00)
    .clipLo_(0.0)
    .clipHi_(1e-3)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(4)
    .action_({
        arg obj;
        var tba_threshi;
        tba_threshi = obj.value.linlin(0.0, 1.0, 0.0, 1e-3);
        k[0].valueAction_(tba_threshi);
    });

    ~nb_tba_lo = NumberBox(w, Rect(80, 105, 50, 20))
    .value_(0.00)
    .clipLo_(0.00)
    .clipHi_(0.001)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(4)
    .action_({
        arg obj;
        var tba_threslo;
        tba_threslo = obj.value;
		tba_threslo = obj.value.linlin(0.0, 1.0, 0.0, 0.001);
        k[1].valueAction_(tba_threslo);
    });
	
    ~nb_fba = NumberBox(w, Rect(220, 105, 50, 20))
    .value_(0.00)
    .clipLo_(0.00)
    .clipHi_(1.0)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(4)
    .action_({
        arg obj;
        var fba_thres;
        fba_thres = obj.value;
		fba_thres = obj.value.linlin(0.0, 1.0, 0.0, 1.0);
        k[2].valueAction_(fba_thres)
    });
	
	/*
	~numberbox = Array.fill(2, NumberBox(w, Rect(110, 30, 50, 20))
	.value_(0.0)
    .clipLo_(0.0)
    .clipHi_(1e-3)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(10)
    .action_({
        arg obj;
        var val;
        //val = ~threshi;
        //k[0].valueAction_(val)
	}));

	*/

	
	/*
	//Carrier_Freq
    k[0].action_({
        |obj| //_________________vvvvvvvvvvvvvvvvv__Range 100Hz-4444Hz
        ~carf = obj.value.linexp (0.0,1.0,100,4444).round(0.1).postln;
        ~numboxcarf.value_(obj.value.linexp(0, 1, 100, 4444));//GoesToNumBox
         funcs0 = [
            {SinOsc.ar(~carf, mul: k[1].value.round(0.01))},
            { Saw.ar(~carf, k[1].value.round(0.01)) },
            { VarSaw.ar(~carf, mul:k[1].value.round(0.01)) },
            { Pulse.ar(~carf, mul: k[1].value.round(0.01)) }
    ];
    });
	
    //Carrier_Amp
    k[1].action_({
        |obj1|
        ~camp = obj1.value.round(0.01).postln;
        ~numboxcaramp.value_(obj1.value);//GoesToNumBox
         funcs0 = [
            {SinOsc.ar(k[0].value.linexp (0.0,1.0,100,4444).round(0.1), mul: ~camp)},
            { Saw.ar(k[0].value.linexp (0.0,1.0,100,4444).round(0.1), ~camp) },
        { VarSaw.ar(k[0].value.linexp (0.0,1.0,100,4444).round(0.1), mul: ~camp)},
        { Pulse.ar(k[0].value.linexp (0.0,1.0,100,4444).round(0.1), mul: ~camp) }
    ];
    });
     //Mod_Freq
    k[2].action_({
        |obj|
        ~modf = obj.value.linexp (0.0,1.0, 1,666).round(0.1).postln;
        ~numboxmodf.value_(obj.value.linexp(0.0, 1.0, 1, 666));//GoesToNumBox
         funcs1 = [
        {SinOsc.kr(~modf, mul: ~modamp)},
        { Saw.kr(~modf, ~modamp) },
        { VarSaw.kr(~modf,mul: ~modamp) },
        { Pulse.kr(~modf, mul: ~modamp) }
    ];
    });
    //Mod_Depth
    k[3].action_({
        |obj1|
        ~modamp = obj1.value.round(0.01).postln;
        ~numboxmodamp.value_(obj1.value);//GoesToNumberBox
        funcs1 = [
        {SinOsc.kr(k[2].value.linexp(0.0, 1.0, 1, 666).round(0.1), mul: ~modamp)},
        { Saw.kr(k[2].value.linexp(0.0, 1.0, 1, 666).round(0.1), ~modamp) },
        { VarSaw.kr(k[2].value.linexp(0.0, 1.0, 1, 666).round(0.1), mul: ~modamp)},
        { Pulse.kr(k[2].value.linexp(0.0, 1.0, 1, 666).round(0.1), mul: ~modamp) }
    ];
    });
    //CarrierFreqNumBox
    ~numboxcarf = NumberBox(w, Rect(110, 30, 50, 20))
    .value_(100)
    .clipLo_(100)
    .clipHi_(4444)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(2)
    .action_({
        arg obj;
        var waw;
        waw = obj.value.explin(100, 4444, 0.0, 1.0);
        k[0].valueAction_(waw)
    });
    //CarrierAmpNumBox
    ~numboxcaramp = NumberBox(w, Rect(205, 30, 50, 20))
    .value_(0.5)
    .clipLo_(0.0)
    .clipHi_(1.0)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(2)
    .action_({
        arg obj;
        var waw;
        waw = obj.value.explin(100, 4444, 0.0, 1.0);
        k[1].valueAction_(waw)
    });
    //ModFreqNumBox
    ~numboxmodf = NumberBox(w, Rect(110, 80, 50, 20))
    .value_(1)
    .clipLo_(1)
    .clipHi_(666)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(2)
    .action_({
        arg obj;
        var waw;
        waw = obj.value.explin(1, 666, 0.0, 1.0);
        k[2].valueAction_(waw)
    });
    //ModAmpNumBox
    ~numboxmodamp = NumberBox(w, Rect(205, 80, 50, 20))
    .value_(0.5)
    .clipLo_(0.0)
    .clipHi_(1.0)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(2)
    .action_({
        arg obj;
        var waw;
        waw = obj.value.explin(100, 4444, 0.0, 1.0);
        k[3].valueAction_(waw)
    });
    //Static_Txt--->Hz
    ~text = Array.fill( 2, {StaticText (w , Rect (200, 175, 100, 20))
        .string_("Hz")
        .font_(Font("Times New Roman", 14))
        .align_(\center)
        .background_(Color.gray)
        .stringColor_(Color.red)});
    ~text[0].bounds_(Rect(163, 30, 20, 20));
    ~text[1].bounds_(Rect(163, 80, 20, 20));
    //Static_Txt--->Amp
    ~text2 = Array.fill( 2, {StaticText (w , Rect (200, 175, 100, 20))
        .string_("Amp")
        .font_(Font("Times New Roman", 12))
        .align_(\center)
        .background_(Color.gray)
        .stringColor_(Color.red)});
    ~text2[0].bounds_(Rect(260, 30, 25, 20));
    ~text2[1].bounds_(Rect(260, 80, 25, 20));
    //Static_Txt--->Car
    ~textcar = StaticText (w , Rect (200, 175, 100, 20))
        .string_("Carrier")
        .font_(Font("Times New Roman", 14))
        .align_(\center)
        .background_(Color.gray)
        .stringColor_(Color.black);
    ~textcar.bounds_(Rect(10, 30, 50, 20));
    //Static_Txt--->Mod
    ~textcar = StaticText (w , Rect (200, 175, 100, 20))
        .string_("Modulator")
        .font_(Font("Times New Roman", 14))
        .align_(\center)
        .background_(Color.gray)
        .stringColor_(Color.black);
    ~textcar.bounds_(Rect(10, 80, 60, 20));
    //Scope
    ~scope = FreqScopeView(w, Rect(10,30,220,900),s);
    ~scope.bounds_(Rect(10,140,275, 55));
    ~scope.active_(true);
    ~scope.front;
    ~scope.background_(Color.gray(0.65));

    b = Button(w, Rect(10, 113, 100, 20))
    .states_([["PLAY", Color.black, Color.new255(240, 245, 255)]])
        .font_(Font("Times New Roman", 12, true)) .mouseDownAction_({
        snd =
        { funcs0.at(menu.value)!2 * funcs1.at(menu1.value)!2}.play;// When Pressed---Play Carrier * Modulator__RingModulationSynthesis!!
    }).action_({
    snd.release; //Release the snd if anything else happens
   });

 p = CmdPeriod.add({ b.value_(0) }); // set button to 0 on hitting Cmd-period
 w.onClose_{ snd.release; CmdPeriod.removeAll; s.freeAll; ~scope.kill; }; // clean up when window is closed
    //Initialization
    k[0].value_(0.00);
    k[1].value_(0.50);
    k[2].value_(0.00);
    k[3].value_(0.50);
    //Iniatilization
    ~carf = 100;
    ~modf = 1;
    ~camp = 0.5;
    ~modamp = 0.5;
	*/
		});
)