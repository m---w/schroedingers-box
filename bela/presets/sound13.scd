~sound13var1 = Buffer.readChannel(s, ~path+/+"./sounds/water-glass_var01.wav", channels:1);
~sound13var2 = Buffer.readChannel(s, ~path+/+"./sounds/water-glass_var02.wav", channels:1);
~sound13var3 = Buffer.readChannel(s, ~path+/+"./sounds/water-glass_var03.wav", channels:1);
~sound13var4 = Buffer.readChannel(s, ~path+/+"./sounds/water-glass_var04.wav", channels:1);
~sound13var5 = Buffer.readChannel(s, ~path+/+"./sounds/water-glass_var05.wav", channels:1);
~sound13var6 = Buffer.readChannel(s, ~path+/+"./sounds/water-glass_var06.wav", channels:1);


~sound = [~sound13var1, ~sound13var2, ~sound13var3, ~sound13var4, ~sound13var5, ~sound13var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 6;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;
