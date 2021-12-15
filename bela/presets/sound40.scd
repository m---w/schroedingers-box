//primary sound
~sound40var1 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var01.wav", channels:1);
~sound40var2 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var02.wav", channels:1);
~sound40var3 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var03.wav", channels:1);
~sound40var4 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var04.wav", channels:1);
~sound40var5 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var05.wav", channels:1);
~sound40var6 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var06.wav", channels:1);
~sound40var7 = Buffer.readChannel(s, ~path+/+"./sounds/cage-bars_var07.wav", channels:1);

//playback array
~sound = [~sound40var1, ~sound40var2, ~sound40var3, ~sound40var4, ~sound40var5, ~sound40var6, ~sound40var7];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
 
//secondary sound
~sound40cat1 = Buffer.read(s, ~path+/+"./sounds/lion_var01.wav");
~sound40cat2 = Buffer.read(s, ~path+/+"./sounds/lion_var02.wav");
~sound40cat3 = Buffer.read(s, ~path+/+"./sounds/lion_var03.wav");
~sound40cat4 = Buffer.read(s, ~path+/+"./sounds/lion_var04.wav");
~sound40cat5 = Buffer.read(s, ~path+/+"./sounds/lion_var05.wav");
~sound40cat6 = Buffer.read(s, ~path+/+"./sounds/lion_var06.wav");
~sound40cat7 = Buffer.read(s, ~path+/+"./sounds/lion_var07.wav");
~sound40cat8 = Buffer.read(s, ~path+/+"./sounds/lion_var08.wav");
~sound40cat9 = Buffer.read(s, ~path+/+"./sounds/lion_var09.wav");

~soundcat_sum = [~sound40cat1, ~sound40cat2, ~sound40cat3, ~sound40cat4, ~sound40cat5, ~sound40cat6, ~sound40cat7,  ~sound40cat8, ~sound40cat9];

//secondary sound flag 
~addsound = true;
//no outcome sound (eg glass break)
~outcome = false;
//number of voices
~voices = 3;

//amplitude configuration
~ampfactor = 9.neg;
~ampfactorcat = 0.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//secondary cuttoff freq
~secondaryCutoff = 20021;

//Comb Filter config
~combFilterDryWet = 1.0;

//hpf primary
~hpfPrimary = 100.0;