~sound3var1 = Buffer.readChannel(s, ~path+/+"./sounds/metaliko_kouti_diafores _attakes_var1.wav", channels:1);
~sound3var2 = Buffer.readChannel(s, ~path+/+"./sounds/metaliko_kouti_diafores _attakes_var2.wav", channels:1);
~sound3var3 = Buffer.readChannel(s, ~path+/+"./sounds/metaliko_kouti_diafores _attakes_var3.wav", channels:1);

~sound = [~sound3var1, ~sound3var2, ~sound3var3];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 1.5.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB

//Comb Filter config
~combFilterDryWet = 1.0;
