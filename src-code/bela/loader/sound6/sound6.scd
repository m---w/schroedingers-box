//primary sound
~sound6var1 = Buffer.readChannel(s, "./sounds/wood_hitting01.wav", channels:1);
~sound6var2 = Buffer.readChannel(s, "./sounds/wood_hitting02.wav", channels:1);
~sound6var3 = Buffer.readChannel(s, "./sounds/wood_hitting03.wav", channels:1);

//playback array
~sound = [~sound6var1, ~sound6var2, ~sound6var3];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
//secondary sound
~sound6cat1 = Buffer.read(s, "./sounds/cat_01.wav");
~sound6cat2 = Buffer.read(s, "./sounds/cat_02.wav");
~sound6cat3 = Buffer.readChannel(s, "./sounds/cat_03.wav", channels:1);
~sound6cat4 = Buffer.readChannel(s, "./sounds/cat_04.wav", channels:1);
~sound6cat5 = Buffer.read(s, "./sounds/cat_05.wav");
~sound6cat6 = Buffer.read(s, "./sounds/cat_06.wav");
~soundcat_sum = [~sound6cat1, ~sound6cat2, ~sound6cat3, ~sound6cat4, ~sound6cat5, ~sound6cat6];

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
