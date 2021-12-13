~sound5var1 = Buffer.readChannel(s, ~path+/+"./sounds/35dogtoy_var1.wav", channels:1);
~sound5var2 = Buffer.readChannel(s, ~path+/+"./sounds/35dogtoy_var2.wav", channels:1);

~sound = [~sound5var1, ~sound5var2];

~addsound = false;
~outcome = false;
~voices = 1;

//amplitude configuration
~ampfactor = 5.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB

//Comb Filter config
~combFilterDryWet = 1.0.neg;