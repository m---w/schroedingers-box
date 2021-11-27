~sound23var1 = Buffer.read(s, "./sounds/book-pages-chattering_var01.wav");
~sound23var2 = Buffer.read(s, "./sounds/book-pages-chattering_var02.wav");
~sound23var3 = Buffer.read(s, "./sounds/book-pages-chattering_var03.wav");
~sound23var4 = Buffer.read(s, "./sounds/book-pages-chattering_var04.wav");
~sound23var5 = Buffer.read(s, "./sounds/book-pages-chattering_var05.wav");

~sound = [~sound23var1, ~sound23var2, ~sound23var3, ~sound23var4, ~sound23var5];

~addsound = false;
~outcome = false;
~voices = 5;

//amplitude configuration
~ampfactor = 10.neg;
~ampfactorcat = inf.neg;
//send amplitude config to bela
n.do{|item| item.sendMsg(\bela, \mainDB, ~ampfactor) }; // send mainDB config to Bela
n.do{|item| item.sendMsg(\bela, \catDB, ~ampfactorcat) }; // send catDB 
