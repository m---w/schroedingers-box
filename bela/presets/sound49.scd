//primary sound
~sound49var1 = Buffer.readChannel(s, ~path+/+"./sounds/boiler-click_var01.wav", channels:0);
~sound49var2 = Buffer.readChannel(s, ~path+/+"./sounds/boiler-click_var02.wav", channels:0);
~sound49var3 = Buffer.readChannel(s, ~path+/+"./sounds/boiler-click_var03.wav", channels:0);
~sound49var4 = Buffer.readChannel(s, ~path+/+"./sounds/boiler-click_var04.wav", channels:0);

//playback array
~sound = [~sound49var1, ~sound49var2, ~sound49var3, ~sound49var4];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
//secondary sound
~sound49cat1 = Buffer.readChannel(s, ~path+/+"./sounds/boiler.wav", channels:0);

~soundcat_sum = [~sound49cat1, ~sound49cat1];

//secondary sound flag 
~addsound = true;
//no outcome sound (eg glass break)
~outcome = false;
//number of voices
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = 10.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 

//Comb Filter config
~combFilterDryWet = 1.0;