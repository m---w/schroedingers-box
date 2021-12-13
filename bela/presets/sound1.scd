~sound1var1 = Buffer.readChannel(s, ~path+/+"./sounds/atakes_vasi_ixeion_me_kleidi_var01.wav", channels:1);
~sound1var2 = Buffer.readChannel(s, ~path+/+"./sounds/atakes_vasi_ixeion_me_kleidi_var02.wav", channels:1);
~sound1var3 = Buffer.readChannel(s, ~path+/+"./sounds/atakes_vasi_ixeion_me_kleidi_var03.wav", channels:1);
~sound1var4 = Buffer.readChannel(s, ~path+/+"./sounds/atakes_vasi_ixeion_me_kleidi_var04.wav", channels:1);
~sound1var5 = Buffer.readChannel(s, ~path+/+"./sounds/atakes_vasi_ixeion_me_kleidi_var05.wav", channels:1);

~sound = [~sound1var1, ~sound1var2, ~sound1var3, ~sound1var4, ~sound1var5];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 0.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB

//Comb Filter config
~combFilterDryWet = 1.0;
