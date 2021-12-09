~sound35var1 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var01.wav", channels:1);
~sound35var2 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var02.wav", channels:1);
~sound35var3 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var03.wav", channels:1);
~sound35var4 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var04.wav", channels:1);
~sound35var5 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var05.wav", channels:1);
~sound35var6 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var06.wav", channels:1);
~sound35var7 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var07.wav", channels:1);
~sound35var8 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var08.wav", channels:1);
~sound35var9 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var09.wav", channels:1);
~sound35var10 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var010.wav", channels:1);
~sound35var11 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var011.wav", channels:1);
~sound35var12 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var012.wav", channels:1);
~sound35var13 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var013.wav", channels:1);
~sound35var14 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var014.wav", channels:1);
~sound35var15 = Buffer.readChannel(s, ~path+/+"./sounds/punch_var015.wav", channels:1);


~sound = [~sound35var1, ~sound35var2, ~sound35var3, ~sound35var4, ~sound35var5, ~sound35var6, ~sound35var7, ~sound35var8, ~sound35var9, ~sound35var10, ~sound35var11, ~sound35var12, ~sound35var13, ~sound35var14, ~sound35var15];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
