~sound21var1 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var01.wav", channels:1);
~sound21var2 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var02.wav", channels:1);
~sound21var3 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var03.wav", channels:1);
~sound21var4 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var04.wav", channels:1);
~sound21var5 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var05.wav", channels:1);
~sound21var6 = Buffer.readChannel(s, ~path+/+"./sounds/thermo-metallic_var06.wav", channels:1);

~sound = [~sound21var1, ~sound21var2, ~sound21var3, ~sound21var4, ~sound21var5, ~sound21var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 3.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;