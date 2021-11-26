~sound9var1 = Buffer.read(s, "./sounds/firework_var01.wav");
~sound9var2 = Buffer.read(s, "./sounds/firework_var02.wav");
~sound9var3 = Buffer.read(s, "./sounds/firework_var03.wav");
~sound9var4 = Buffer.read(s, "./sounds/firework_var04.wav");
~sound9var5 = Buffer.read(s, "./sounds/firework_var05.wav");

~sound = [~sound9var1, ~sound9var2, ~sound9var3, ~sound9var4, ~sound9var5];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
