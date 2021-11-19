~sound20var1 = Buffer.readChannel(s, "./sounds/wood-tup_var01.wav", channels:1);
~sound20var2 = Buffer.readChannel(s, "./sounds/wood-tup_var02.wav", channels:1);
~sound20var3 = Buffer.readChannel(s, "./sounds/wood-tup_var03.wav", channels:1);
~sound20var4 = Buffer.readChannel(s, "./sounds/wood-tup_var04.wav", channels:1);
~sound20var5 = Buffer.readChannel(s, "./sounds/wood-tup_var05.wav", channels:1);
~sound20var6 = Buffer.readChannel(s, "./sounds/wood-tup_var06.wav", channels:1);

//playback array
~sound = [~sound20var1, ~sound20var2, ~sound20var3, ~sound20var4, ~sound20var5, ~sound20var6];

//buffer load and initialisation
~soundstopped = 0; //do not play cat on every detected impact
~onset_sum = 0; //when there are multiple and continuous impacts then trigger cat
~sound20cat1 = Buffer.read(s, "./sounds/cheer_var01.wav");
~sound20cat2 = Buffer.read(s, "./sounds/cheer_var02.wav");
~sound20cat3 = Buffer.readChannel(s, "./sounds/cheer_var03.wav", channels:1);
~sound20cat4 = Buffer.readChannel(s, "./sounds/cheer_var04.wav", channels:1);
//~sound20cat5 = Buffer.read(s, "./sounds/cat_05.wav");
//~sound20cat6 = Buffer.read(s, "./sounds/cat_020.wav");
~soundcat_sum = [~sound20cat1, ~sound20cat2, ~sound20cat3, ~sound20cat4];//, ~sound20cat5, ~sound20cat20];

~addsound = true;
~outcome = false;
~voices = 5;