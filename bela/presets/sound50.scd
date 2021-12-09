~sound50var1 = Buffer.readChannel(s, ~path+/+"./sounds/coolness-imp_var01.wav", channels:0);
~sound50var2 = Buffer.readChannel(s, ~path+/+"./sounds/coolness-imp_var02.wav", channels:0);
~sound50var3 = Buffer.readChannel(s, ~path+/+"./sounds/coolness-imp_var03.wav", channels:0);
~sound50var4 = Buffer.readChannel(s, ~path+/+"./sounds/coolness-imp_var04.wav", channels:0);
~sound50var5 = Buffer.readChannel(s, ~path+/+"./sounds/coolness-imp_var05.wav", channels:0);
~sound50var6 = Buffer.readChannel(s, ~path+/+"./sounds/coolness-imp_var06.wav", channels:0);

~sound = [~sound50var1, ~sound50var2, ~sound50var3, ~sound50var4, ~sound50var5, ~sound50var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
