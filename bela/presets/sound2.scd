~sound1 = Buffer.readChannel(s, ~path+/+"./sounds/kagelo01.wav", channels:1);
~sound2 = Buffer.readChannel(s, ~path+/+"./sounds/kagelo02.wav", channels:1);

~sound = [~sound1, ~sound2];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 0.neg;
~ampfactorcat = inf.neg;


//Comb Filter config
~combFilterDryWet = 0.0;
