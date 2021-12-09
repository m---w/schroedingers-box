~sound18var1 = Buffer.readChannel(s, ~path+/+"./sounds/spray_var01.wav", channels:1);
~sound18var2 = Buffer.readChannel(s, ~path+/+"./sounds/spray_var02.wav", channels:1);
~sound18var3 = Buffer.readChannel(s, ~path+/+"./sounds/spray_var03.wav", channels:1);
~sound18var4 = Buffer.readChannel(s, ~path+/+"./sounds/spray_var04.wav", channels:1);
~sound18var5 = Buffer.readChannel(s, ~path+/+"./sounds/spray_var05.wav", channels:1);


~sound = [~sound18var1, ~sound18var2, ~sound18var3, ~sound18var4, ~sound18var5];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
