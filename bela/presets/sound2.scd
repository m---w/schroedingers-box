~sound2var1 = Buffer.readChannel(s, ~path+/+"./sounds/kagelo01.wav", channels:1);
~sound2var2 = Buffer.readChannel(s, ~path+/+"./sounds/kagelo02.wav", channels:1);

~sound = [~sound2var1, ~sound2var2];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 0.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;
