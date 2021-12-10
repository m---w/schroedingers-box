~sound28var1 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var01.wav", channels:1);
~sound28var2 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var02.wav", channels:1);
~sound28var3 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var03.wav", channels:1);
~sound28var4 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var04.wav", channels:1);
~sound28var5 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var05.wav", channels:1);
~sound28var6 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var06.wav", channels:1);
~sound28var7 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var07.wav", channels:1);
~sound28var8 = Buffer.readChannel(s, ~path+/+"./sounds/cough_var08.wav", channels:1);

~sound = [~sound28var1, ~sound28var2, ~sound28var3, ~sound28var4, ~sound28var5, ~sound28var6, ~sound28var7,  ~sound28var8];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0.neg;