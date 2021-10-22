/*
	Schroedinger's Box
	SuperCollider Control Patch for Bela
	2021 Jason Svoronos-Kanavas, Marian Weger 
*/

(
Window.closeAll;
s.waitForBoot({

	var w, tba_threshi, tba_threslo, fba_thres;
	
	//~n = NetAddr("192.168.184.21", 57120);
	~n = NetAddr("bela.local", 57120);
	

    w = Window("Schroedinger's box control").alwaysOnTop_(true);
    w.bounds_(Rect(900, 500, 300, 300));
    w.view.background_(Color(0.1, 0.1, 0.1));
    w.front;

    tba_threshi = 0;
	tba_threslo = 0;

	fba_thres = 0;

	~text = Array.fill( 7, {StaticText (w , Rect (200, 175, 100, 20))
        .string_("TBA_thres_high")
        .font_(Font("Times New Roman", 15))
        .align_(\center)
        .background_(Color(0.1, 0.1, 0.1))
        .stringColor_(Color.red)});
    ~text[0].bounds_(Rect(8, 0, 120, 20)).string_("TBA");
    ~text[1].bounds_(Rect(-10, 25, 100, 10)).string_("hi-th.").stringColor_(Color.white);
	~text[2].bounds_(Rect(80, 25, 50, 10)).string_("lo-th.").stringColor_(Color.white);
	~text[3].bounds_(Rect(180, 0, 120, 20)).string_("FBA");
	~text[4].bounds_(Rect(180, 20, 120, 20)).string_("thres.").stringColor_(Color.white);
    ~text[5].bounds_(Rect(215, 190, 120, 20)).string_("cat").stringColor_(Color.white);
	~text[6].bounds_(Rect(105, 190, 120, 20)).string_("main").stringColor_(Color.white);
	
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
		val = obj.value.linlin(0.0, 1.0, 0.0, 5.0);
		val.postln;
		//q.set only local no osc
		//q.set(\fba_thres, val);
		//sendMsg to bela
		~n.sendMsg('/thres/fba_thres', val);
        ~nb_fba.value_(val.value);//GoesToNumberBox
	});
	
	~nb_tba_hi = NumberBox(w, Rect(3, 105, 70, 20))
    .value_(0.00)
    .clipLo_(0.0)
    .clipHi_(1e-3)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(6)
    .action_({
        arg obj;
        var tba_threshi;
        tba_threshi = obj.value.linlin(0.0, 1.0, 0.0, 1e-3);
        k[0].valueAction_(tba_threshi);
    });

    ~nb_tba_lo = NumberBox(w, Rect(80, 105, 70, 20))
    .value_(0.00)
    .clipLo_(0.00)
    .clipHi_(0.001)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(6)
    .action_({
        arg obj;
        var tba_threslo;
        tba_threslo = obj.value;
		tba_threslo = obj.value.linlin(0.0, 1.0, 0.0, 0.001);
        k[1].valueAction_(tba_threslo);
    });
	
    ~nb_fba = NumberBox(w, Rect(220, 105, 70, 20))
    .value_(0.00)
    .clipLo_(0.00)
    .clipHi_(5.0)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(6)
    .action_({
        arg obj;
        var fba_thres;
        fba_thres = obj.value;
		//fba_thres = obj.value.linlin(0.0, 1.0, 0.0, 1.0);
        k[2].valueAction_(fba_thres)
    });

	~sample_picker = NumberBox(w, Rect(120, 175, 20, 20))
    .value_(0.00)
    .clipLo_(0.00)
    .clipHi_(70.0)
    .font_(Font ("Times New Roman",16))
    .background_ (Color.new255(240, 240, 255))
    .decimals_(0)
    .action_({
        arg obj;
        var sam_num;
		sam_num = obj.value;
		~n.sendMsg('/soundpick/2', \sam_num, sam_num);
    });


	//master fader sliders
	k = Array.fill(2, {Slider(w, Rect(0,100,30,130))});
    k[0].bounds_(Rect(185, 150, 30, 130)).value_(1);//main sounds
    k[1].bounds_(Rect(230, 150, 30, 130)).value_(1);//cat sounds
    k[0].action_({
        |obj|
		var master;
		master = obj.value.squared;
        //~numboxcarf.value_(obj.value.linexp(0, 1, 100, 4444));//GoesToNumBox
		~n.sendMsg('/master', \main, master);
	});
	k[1].action_({
        |obj|
		var master;
		master = obj.value.squared;
        //~numboxcarf.value_(obj.value.linexp(0, 1, 100, 4444));//GoesToNumBox
		~n.sendMsg('/master', \cat, master);
	});

	
});
)