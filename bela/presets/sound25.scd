~sound25var1 = Buffer.readChannel(s, ~path+/+"./sounds/fan-rattle_var01.wav", channels:1);
~sound25var2 = Buffer.readChannel(s, ~path+/+"./sounds/fan-rattle_var02.wav", channels:1);
~sound25var3 = Buffer.readChannel(s, ~path+/+"./sounds/fan-rattle_var03.wav", channels:1);
~sound25var4 = Buffer.readChannel(s, ~path+/+"./sounds/fan-rattle_var04.wav", channels:1);
~sound25var5 = Buffer.readChannel(s, ~path+/+"./sounds/fan-rattle_var05.wav", channels:1);

~sound = [~sound25var1, ~sound25var2, ~sound25var3, ~sound25var4, ~sound25var5];

~addsound = false;
~outcome = false;
~voices = 3;

//amplitude configuration
~ampfactor = 8;
~ampfactorcat = inf.neg;

//Comb Filter config
~combFilterDryWet = 1.0;
