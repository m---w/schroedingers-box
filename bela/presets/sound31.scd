~sound31var1 = Buffer.readChannel(s, ~path+/+"./sounds/micro-ding_var01.wav", channels:1);
~sound31var2 = Buffer.readChannel(s, ~path+/+"./sounds/micro-ding_var02.wav", channels:1);
~sound31var3 = Buffer.readChannel(s, ~path+/+"./sounds/micro-ding_var03.wav", channels:1);
~sound31var4 = Buffer.readChannel(s, ~path+/+"./sounds/micro-ding_var04.wav", channels:1);
~sound31var5 = Buffer.readChannel(s, ~path+/+"./sounds/micro-ding_var05.wav", channels:1);
~sound31var6 = Buffer.readChannel(s, ~path+/+"./sounds/micro-ding_var06.wav", channels:1);

~sound = [~sound31var1, ~sound31var2, ~sound31var3, ~sound31var4, ~sound31var5, ~sound31var6];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 12;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;
