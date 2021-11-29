~sound27var1 = Buffer.readChannel(s, "./sounds/toasterx_var01.wav", channels:1);
~sound27var2 = Buffer.readChannel(s, "./sounds/toasterx_var02.wav", channels:1);
~sound27var3 = Buffer.readChannel(s, "./sounds/toasterx_var03.wav", channels:1);
~sound27var4 = Buffer.readChannel(s, "./sounds/toasterx_var04.wav", channels:1);
~sound27var5 = Buffer.readChannel(s, "./sounds/toasterx_var05.wav", channels:1);
~sound27var6 = Buffer.readChannel(s, "./sounds/toasterx_var06.wav", channels:1);

~sound = [~sound27var1, ~sound27var2, ~sound27var3, ~sound27var4, ~sound27var5, ~sound27var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
