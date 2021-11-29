~sound34var1 = Buffer.readChannel(s, "./sounds/water-splash_var01.wav", channels:1);
~sound34var2 = Buffer.readChannel(s, "./sounds/water-splash_var02.wav", channels:1);
~sound34var3 = Buffer.readChannel(s, "./sounds/water-splash_var03.wav", channels:1);
~sound34var4 = Buffer.readChannel(s, "./sounds/water-splash_var04.wav", channels:1);
~sound34var5 = Buffer.readChannel(s, "./sounds/water-splash_var05.wav", channels:1);
~sound34var6 = Buffer.readChannel(s, "./sounds/water-splash_var06.wav", channels:1);

~sound = [~sound34var1, ~sound34var2, ~sound34var3, ~sound34var4, ~sound34var5, ~sound34var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
