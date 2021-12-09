~sound47var1 = Buffer.readChannel(s, ~path+/+"./sounds/metallic-box-w-nuts-inside_var01.wav", channels:0);
~sound47var2 = Buffer.readChannel(s, ~path+/+"./sounds/metallic-box-w-nuts-inside_var02.wav", channels:0);
~sound47var3 = Buffer.readChannel(s, ~path+/+"./sounds/metallic-box-w-nuts-inside_var03.wav", channels:0);
~sound47var4 = Buffer.readChannel(s, ~path+/+"./sounds/metallic-box-w-nuts-inside_var04.wav", channels:0);
~sound47var5 = Buffer.readChannel(s, ~path+/+"./sounds/metallic-box-w-nuts-inside_var05.wav", channels:0);
~sound47var6 = Buffer.readChannel(s, ~path+/+"./sounds/metallic-box-w-nuts-inside_var06.wav", channels:0);

~sound = [~sound47var1, ~sound47var2, ~sound47var3, ~sound47var4, ~sound47var5, ~sound47var6];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
