//primary sound
~sound53var1 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var01.wav", channels:0);
~sound53var2 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var02.wav", channels:0);
~sound53var3 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var03.wav", channels:0);
~sound53var4 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var04.wav", channels:0);
~sound53var5 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var05.wav", channels:0);
~sound53var6 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var06.wav", channels:0);
~sound53var7 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var07.wav", channels:0);
~sound53var8 = Buffer.readChannel(s, ~path+/+"./sounds/aluminum-impact_var08.wav", channels:0);


//playback array
~sound = [~sound6var1, ~sound6var2, ~sound6var3, ~sound6var4, ~sound6var5, ~sound6var6, ~sound6var7, ~sound6var8];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
//secondary sound
~sound53cat1 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var01.wav", channels:0);
~sound53cat2 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var02.wav", channels:0);
~sound53cat3 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var03.wav", channels:0);
~sound53cat4 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var04.wav", channels:0);
~sound53cat5 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var05.wav", channels:0);
~sound53cat6 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var06.wav", channels:0);
~sound53cat7 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var07.wav", channels:0);
~sound53cat8 = Buffer.readChannel(s, ~path+/+"./sounds/nails-drop_var08.wav", channels:0);

~soundcat_sum = [~sound6cat1, ~sound6cat2, ~sound6cat3, ~sound6cat4, ~sound6cat5, ~sound6cat6, ~sound6cat7, ~sound6cat8];

//secondary sound flag 
~addsound = true;
//no outcome sound (eg glass break)
~outcome = false;
//number of voices
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = 20.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;