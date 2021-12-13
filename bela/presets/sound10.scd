~sound10var1 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-hit_var01.wav", channels:1);
~sound10var2 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-hit_var02.wav", channels:1);
~sound10var3 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-hit_var03.wav", channels:1);
~sound10var4 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-hit_var04.wav", channels:1);
~sound10var5 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-hit_var05.wav", channels:1);

~soundoutcomevar1 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-break_var01.wav", channels:1);
~soundoutcomevar2 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-break_var02.wav", channels:1);
~soundoutcomevar3 = Buffer.readChannel(s, ~path+/+"./sounds/bottle-break_var03.wav", channels:1);

~sound = [~sound10var1, ~sound10var2, ~sound10var3, ~sound10var4, ~sound10var5];

~soundcat_sum = [~soundoutcomevar1, ~soundoutcomevar2, ~soundoutcomevar3];

~addsound = false;
~outcome = true;
~voices = 5;

//amplitude configuration
~ampfactor = 2.5;
~ampfactorcat = 2.5;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB

//Comb Filter config
~combFilterDryWet = 1.0;