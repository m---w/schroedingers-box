~sound17var1 = Buffer.readChannel(s, ~path+/+"./sounds/plastic-container-impact_var01.wav", channels:1);
~sound17var2 = Buffer.readChannel(s, ~path+/+"./sounds/plastic-container-impact_var02.wav", channels:1);
~sound17var3 = Buffer.readChannel(s, ~path+/+"./sounds/plastic-container-impact_var03.wav", channels:1);
~sound17var4 = Buffer.readChannel(s, ~path+/+"./sounds/plastic-container-impact_var04.wav", channels:1);
~sound17var5 = Buffer.readChannel(s, ~path+/+"./sounds/plastic-container-impact_var05.wav", channels:1);
~sound17var6 = Buffer.readChannel(s, ~path+/+"./sounds/plastic-container-impact_var06.wav", channels:1);


~sound = [~sound17var1, ~sound17var2, ~sound17var3, ~sound17var4, ~sound17var5, ~sound17var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
