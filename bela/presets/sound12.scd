
~sound = Array.newClear(5);

~sound[0] = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/harpsi_var01.wav", channels: 0);
~sound[1] = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/harpsi_var02.wav", channels: 0);
~sound[2] = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/harpsi_var03.wav", channels: 0);
~sound[3] = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/harpsi_var04.wav", channels: 0);
~sound[4] = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/harpsi_var05.wav", channels: 0);


~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 0.0;
~ampfactorcat = inf.neg;


//Comb Filter config
~combFilterDryWet = 1.0.neg;
