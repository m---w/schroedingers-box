~sound12var1 = Buffer.readChannel(s, ~path+/+"./sounds/harpsi_var01.wav", channels:1);
~sound12var2 = Buffer.readChannel(s, ~path+/+"./sounds/harpsi_var02.wav", channels:1);
~sound12var3 = Buffer.readChannel(s, ~path+/+"./sounds/harpsi_var03.wav", channels:1);
~sound12var4 = Buffer.readChannel(s, ~path+/+"./sounds/harpsi_var04.wav", channels:1);
~sound12var5 = Buffer.readChannel(s, ~path+/+"./sounds/harpsi_var05.wav", channels:1);


~sound = [~sound12var1, ~sound12var2, ~sound12var3, ~sound12var4, ~sound12var5];

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