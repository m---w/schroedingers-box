~sound39var1 = Buffer.readChannel(s, ~path+/+"./sounds/match_var01.wav", channels:0);
~sound39var2 = Buffer.readChannel(s, ~path+/+"./sounds/match_var02.wav", channels:0);
~sound39var3 = Buffer.readChannel(s, ~path+/+"./sounds/match_var03.wav", channels:0);

//happens only once??
~soundonce = Buffer.readChannel(s, ~path+/+"./sounds/match_light.wav", channels:0);

~soundoutcomevar1 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var01.wav");
~soundoutcomevar2 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var02.wav");
~soundoutcomevar3 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var03.wav");
~soundoutcomevar4 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var04.wav");
~soundoutcomevar5 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var05.wav");
~soundoutcomevar6 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var06.wav");
~soundoutcomevar7 = Buffer.read(s, ~path+/+"./sounds/fire-burst_var07.wav");


~sound = [~sound39var1, ~sound39var2, ~sound39var3];

~soundcat_sum = [~soundoutcomevar1, ~soundoutcomevar2, ~soundoutcomevar3, ~soundoutcomevar4, ~soundoutcomevar5, ~soundoutcomevar6, ~soundoutcomevar7, ~soundonce];

~addsound = false;
~outcome = true;
//only one voice
~voices = 1;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = 20.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0.neg;