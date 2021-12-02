~sound41var1 = Buffer.readChannel(s, "./sounds/sk8_var01.wav", channels:1);
~sound41var2 = Buffer.readChannel(s, "./sounds/sk8_var02.wav", channels:1);
~sound41var3 = Buffer.readChannel(s, "./sounds/sk8_var03.wav", channels:1);
~sound41var4 = Buffer.readChannel(s, "./sounds/sk8_var04.wav", channels:1);
~sound41var5 = Buffer.readChannel(s, "./sounds/sk8_var05.wav", channels:1);
~sound41var6 = Buffer.readChannel(s, "./sounds/sk8_var06.wav", channels:1);
~sound41var7 = Buffer.readChannel(s, "./sounds/sk8_var07.wav", channels:1);
~sound41var8 = Buffer.readChannel(s, "./sounds/sk8_var08.wav", channels:1);

~sound = [~sound41var1, ~sound41var2, ~sound41var3, ~sound41var4, ~sound41var5, ~sound41var6,  ~sound41var7,  ~sound41var8];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
