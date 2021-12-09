//primary sound
~sound51var1 = Buffer.readChannel(s, ~path+/+"./sounds/init-impact_var01.wav", channels:0);
~sound51var2 = Buffer.readChannel(s, ~path+/+"./sounds/init-impact_var02.wav", channels:0);
~sound51var3 = Buffer.readChannel(s, ~path+/+"./sounds/init-impact_var03.wav", channels:0);
~sound51var4 = Buffer.readChannel(s, ~path+/+"./sounds/init-impact_var04.wav", channels:0);
~sound51var5 = Buffer.readChannel(s, ~path+/+"./sounds/init-impact_var05.wav", channels:0);
~sound51var6 = Buffer.readChannel(s, ~path+/+"./sounds/init-impact_var06.wav", channels:0);

//playback array
~sound = [~sound51var1, ~sound51var2, ~sound51var3, ~sound51var4, ~sound51var5, ~sound51var6];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
//secondary sound
~sound51cat1 = Buffer.readChannel(s, ~path+/+"./sounds/silly-duck_var01.wav", channels:0);
~sound51cat2 = Buffer.readChannel(s, ~path+/+"./sounds/silly-duck_var02.wav", channels:0);
~sound51cat3 = Buffer.readChannel(s, ~path+/+"./sounds/silly-duck_var03.wav", channels:0);

~soundcat_sum = [~sound51cat1, ~sound51cat2, ~sound51cat3];

//secondary sound flag 
~addsound = true;
//no outcome sound (eg glass break)
~outcome = false;
//number of voices
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = 13.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
