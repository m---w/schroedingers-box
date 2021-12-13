~sound34var1 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var01.wav", channels:1);
~sound34var2 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var02.wav", channels:1);
~sound34var3 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var03.wav", channels:1);
~sound34var4 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var04.wav", channels:1);
~sound34var5 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var05.wav", channels:1);
~sound34var6 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var06.wav", channels:1);
~sound34var7 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash-light_var07.wav", channels:1);

~soundoutcomevar1 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var01.wav", channels:1);
~soundoutcomevar2 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var02.wav", channels:1);
~soundoutcomevar3 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var03.wav", channels:1);
~soundoutcomevar4 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var04.wav", channels:1);
~soundoutcomevar5 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var05.wav", channels:1);
~soundoutcomevar6 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var06.wav", channels:1);
~soundoutcomevar7 = Buffer.readChannel(s, ~path+/+"./sounds/water-splash_var07.wav", channels:1);

~sound = [~sound34var1, ~sound34var2, ~sound34var3, ~sound34var4, ~sound34var5, ~sound34var6, ~sound34var7];

~soundcat_sum = [~soundoutcomevar1, ~soundoutcomevar2, ~soundoutcomevar3, ~soundoutcomevar4, ~soundoutcomevar5, ~soundoutcomevar6, ~soundoutcomevar7];


~addsound = false;
~outcome = true;
~voices = 3;

//amplitude configuration
~ampfactor = 12;
~ampfactorcat = 10;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0.neg;
