~sound14var1 = Buffer.readChannel(s, "./sounds/physical-plucked-string_var01.wav", channels:1);
~sound14var2 = Buffer.readChannel(s, "./sounds/physical-plucked-string_var02.wav", channels:1);
~sound14var3 = Buffer.readChannel(s, "./sounds/physical-plucked-string_var03.wav", channels:1);
~sound14var4 = Buffer.readChannel(s, "./sounds/physical-plucked-string_var04.wav", channels:1);
~sound14var5 = Buffer.readChannel(s, "./sounds/physical-plucked-string_var05.wav", channels:1);
~sound14var6 = Buffer.readChannel(s, "./sounds/physical-plucked-string_var06.wav", channels:1);


~sound = [~sound14var1, ~sound14var2, ~sound14var3, ~sound14var4, ~sound14var5, ~sound14var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
