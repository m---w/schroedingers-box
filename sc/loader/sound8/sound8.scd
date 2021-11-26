~sound8var1 = Buffer.read(s, "./sounds/10meatknife_var1.wav");
~sound8var2 = Buffer.read(s, "./sounds/10meatknife_var2.wav");

~sound = [~sound8var1, ~sound8var2];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 