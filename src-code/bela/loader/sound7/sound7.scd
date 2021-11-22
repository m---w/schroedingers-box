~sound7var1 = Buffer.read(s, "./sounds/impact.wav");
~sound7var2 = Buffer.read(s, "./sounds/impact1.wav");
~sound7var3 = Buffer.read(s, "./sounds/impact2.wav");
~sound7var4 = Buffer.read(s, "./sounds/impact3.wav");
~sound7var5 = Buffer.read(s, "./sounds/impact4.wav");
~sound7var6 = Buffer.read(s, "./sounds/impact5.wav");

~sound = [~sound7var1, ~sound7var2, ~sound7var3, ~sound7var4, ~sound7var5, ~sound7var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 