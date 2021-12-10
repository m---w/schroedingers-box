//primary sound
~sound42var1 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var01.wav", channels:1);
~sound42var2 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var02.wav", channels:1);
~sound42var3 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var03.wav", channels:1);
~sound42var4 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var04.wav", channels:1);
~sound42var5 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var05.wav", channels:1);
~sound42var6 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var06.wav", channels:1);

//playback array
~sound = [~sound42var1, ~sound42var2, ~sound42var3, ~sound42var4,  ~sound42var5, ~sound42var6];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
//secondary sound
~sound42cat1 = Buffer.read(s, ~path+/+"./sounds/ballon-defl_var01.wav");
~sound42cat2 = Buffer.read(s, ~path+/+"./sounds/ballon-defl_var02.wav");
~sound42cat3 = Buffer.readChannel(s, ~path+/+"./sounds/balloon-defl_var03.wav", channels:0);
~sound42cat4 = Buffer.readChannel(s, ~path+/+"./sounds/ballon-infl_var01.wav", channels:1);
~sound42cat5 = Buffer.readChannel(s, ~path+/+"./sounds/ballon-infl_var02.wav", channels:1);
~sound42cat6 = Buffer.read(s, ~path+/+"./sounds/ballon-infl_var03.wav");
~sound42cat7 = Buffer.read(s, ~path+/+"./sounds/balloon-pop_var_01.wav");
~sound42cat8 = Buffer.read(s, ~path+/+"./sounds/balloon-pop_var_02.wav");
~sound42cat9 = Buffer.read(s, ~path+/+"./sounds/balloon-pop_var_03.wav");
~sound42cat10 = Buffer.read(s, ~path+/+"./sounds/balloon-pop_var_04.wav");
~sound42cat11 = Buffer.read(s, ~path+/+"./sounds/balloon-pop_var_05.wav");
~sound42cat12 = Buffer.read(s, ~path+/+"./sounds/balloon-pop_var_06.wav");
~sound42cat13 = Buffer.readChannel(s, ~path+/+"./sounds/balloon-squeek_var01.wav", channels:0);

~soundcat_sum = [~sound42cat1, ~sound42cat2, ~sound42cat3, ~sound42cat4, ~sound42cat5, ~sound42cat6, ~sound42cat7, ~sound42cat8, ~sound42cat9, ~sound42cat10, ~sound42cat11, ~sound42cat12, ~sound42cat13];

//secondary sound flag 
~addsound = true;
//no outcome sound (eg glass break)
~outcome = false;
//number of voices
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = 20.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;