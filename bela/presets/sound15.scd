~sound15var1 = Buffer.readChannel(s, "./sounds/artificial_var01.wav", channels:1);
~sound15var2 = Buffer.readChannel(s, "./sounds/artificial_var02.wav", channels:1);
~sound15var3 = Buffer.readChannel(s, "./sounds/artificial_var03.wav", channels:1);
~sound15var4 = Buffer.readChannel(s, "./sounds/artificial_var04.wav", channels:1);
~sound15var5 = Buffer.readChannel(s, "./sounds/artificial_var05.wav", channels:1);
~sound15var6 = Buffer.readChannel(s, "./sounds/artificial_var06.wav", channels:1);


~sound = [~sound15var1, ~sound15var2, ~sound15var3, ~sound15var4, ~sound15var5, ~sound15var6];

~addsound = false;
~outcome = false;
~voices = 1;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
