~sound36var1 = Buffer.readChannel(s, ~path+/+"./sounds/lamarina_var01.wav", channels:1);
~sound36var2 = Buffer.readChannel(s, ~path+/+"./sounds/lamarina_var02.wav", channels:1);
~sound36var3 = Buffer.readChannel(s, ~path+/+"./sounds/lamarina_var03.wav", channels:1);
~sound36var4 = Buffer.readChannel(s, ~path+/+"./sounds/lamarina_var04.wav", channels:1);
~sound36var5 = Buffer.readChannel(s, ~path+/+"./sounds/lamarina_var05.wav", channels:1);

~sound = [~sound36var1, ~sound36var2, ~sound36var3, ~sound36var4, ~sound36var5];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
