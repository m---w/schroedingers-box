~sound24var1 = Buffer.readChannel(s, "./sounds/fan-scissors_var01.wav", channels:1);
~sound24var2 = Buffer.readChannel(s, "./sounds/fan-scissors_var02.wav", channels:1);
~sound24var3 = Buffer.readChannel(s, "./sounds/fan-scissors_var03.wav", channels:1);
~sound24var4 = Buffer.readChannel(s, "./sounds/fan-scissors_var04.wav", channels:1);
~sound24var5 = Buffer.readChannel(s, "./sounds/fan-scissors_var05.wav", channels:1);
~sound24var6 = Buffer.readChannel(s, "./sounds/fan-scissors_var06.wav", channels:1);

~sound = [~sound24var1, ~sound24var2, ~sound24var3, ~sound24var4, ~sound24var5, ~sound24var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
