~sound26var1 = Buffer.readChannel(s, "./sounds/spring-wire_var01.wav", channels:1);
~sound26var2 = Buffer.readChannel(s, "./sounds/spring-wire_var02.wav", channels:1);
~sound26var3 = Buffer.readChannel(s, "./sounds/spring-wire_var03.wav", channels:1);
~sound26var4 = Buffer.readChannel(s, "./sounds/spring-wire_var04.wav", channels:1);
~sound26var5 = Buffer.readChannel(s, "./sounds/spring-wire_var05.wav", channels:1);
~sound26var6 = Buffer.readChannel(s, "./sounds/spring-wire_var06.wav", channels:1)

~sound = [~sound26var1, ~sound26var2, ~sound26var3, ~sound26var4, ~sound26var5, ~sound26var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
