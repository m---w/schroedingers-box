~sound19var1 = Buffer.readChannel(s, ~path+/+"./sounds/churchbell_var01.wav", channels:1);
~sound19var2 = Buffer.readChannel(s, ~path+/+"./sounds/churchbell_var02.wav", channels:1);
~sound19var3 = Buffer.readChannel(s, ~path+/+"./sounds/churchbell_var03.wav", channels:1);
~sound19var4 = Buffer.readChannel(s, ~path+/+"./sounds/churchbell_var04.wav", channels:1);
~sound19var5 = Buffer.readChannel(s, ~path+/+"./sounds/churchbell_var05.wav", channels:1);
~sound19var6 = Buffer.readChannel(s, ~path+/+"./sounds/churchbell_var06.wav", channels:1);

~sound = [~sound19var1, ~sound19var2, ~sound19var3, ~sound19var4, ~sound19var5, ~sound19var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
