~sound33var1 = Buffer.readChannel(s, ~path+/+"./sounds/chaotic-drop_var01.wav", channels:1);
~sound33var2 = Buffer.readChannel(s, ~path+/+"./sounds/chaotic-drop_var02.wav", channels:1);
~sound33var3 = Buffer.readChannel(s, ~path+/+"./sounds/chaotic-drop_var03.wav", channels:1);
~sound33var4 = Buffer.readChannel(s, ~path+/+"./sounds/chaotic-drop_var04.wav", channels:1);
~sound33var5 = Buffer.readChannel(s, ~path+/+"./sounds/chaotic-drop_var05.wav", channels:1);
~sound33var6 = Buffer.readChannel(s, ~path+/+"./sounds/chaotic-drop_var06.wav", channels:1);

~sound = [~sound33var1, ~sound33var2, ~sound33var3, ~sound33var4, ~sound33var5, ~sound33var6];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 7;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0.neg;
