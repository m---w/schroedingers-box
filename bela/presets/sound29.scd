~sound29var1 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var01.wav", channels:1);
~sound29var2 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var02.wav", channels:1);
~sound29var3 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var03.wav", channels:1);
~sound29var4 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var04.wav", channels:1);
~sound29var5 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var05.wav", channels:1);
~sound29var6 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var06.wav", channels:1);
~sound29var7 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var07.wav", channels:1);
~sound29var8 = Buffer.readChannel(s, ~path+/+"./sounds/score-mus-stand_var08.wav", channels:1);

~sound = [~sound29var1, ~sound29var2, ~sound29var3, ~sound29var4, ~sound29var5, ~sound29var6, ~sound29var7, ~sound29var8];

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