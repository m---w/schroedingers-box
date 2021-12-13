~sound22var1 = Buffer.readChannel(s, ~path+/+"./sounds/sackl-impact_var01.wav", channels:1);
~sound22var2 = Buffer.readChannel(s, ~path+/+"./sounds/sackl-impact_var02.wav", channels:1);
~sound22var3 = Buffer.readChannel(s, ~path+/+"./sounds/sackl-impact_var03.wav", channels:1);
~sound22var4 = Buffer.readChannel(s, ~path+/+"./sounds/sackl-impact_var04.wav", channels:1);
~sound22var5 = Buffer.readChannel(s, ~path+/+"./sounds/sackl-impact_var05.wav", channels:1);
~sound22var6 = Buffer.readChannel(s, ~path+/+"./sounds/sackl-impact_var06.wav", channels:1);

~sound = [~sound22var1, ~sound22var2, ~sound22var3, ~sound22var4, ~sound22var5, ~sound22var6];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 4;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;
