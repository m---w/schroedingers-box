~sound54var1 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var01.wav", channels:0);
~sound54var2 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var02.wav", channels:0);
~sound54var3 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var03.wav", channels:0);
~sound54var4 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var04.wav", channels:0);
~sound54var5 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var05.wav", channels:0);
~sound54var6 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var06.wav", channels:0);
~sound54var7 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var07.wav", channels:0);
~sound54var8 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var08.wav", channels:0);
~sound54var9 = Buffer.readChannel(s, ~path+/+"./sounds/impact-sackl_var09.wav", channels:0);

~sound = [~sound54var1, ~sound54var2, ~sound54var3, ~sound54var4, ~sound54var5, ~sound54var6, ~sound54var7, ~sound54var8, ~sound54var9];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;