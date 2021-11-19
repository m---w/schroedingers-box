~sound4var1 = Buffer.readChannel(s, "./sounds/timpani_bends1_var1.wav", channels:1);
~sound4var2 = Buffer.readChannel(s, "./sounds/timpani_bends1_var2.wav", channels:1);
~sound4var3 = Buffer.readChannel(s, "./sounds/timpani_bends1_var3.wav", channels:1);
~sound4var4 = Buffer.readChannel(s, "./sounds/timpani_bends1_var4.wav", channels:1);
~sound4var5 = Buffer.readChannel(s, "./sounds/timpani_bends1_var5.wav", channels:1);
~sound4var6 = Buffer.readChannel(s, "./sounds/timpani_bends1_var6.wav", channels:1);

~sound = [~sound4var1, ~sound4var2, ~sound4var3, ~sound4var4, ~sound4var5, ~sound4var6];

~addsound = false;
~outcome = false;
~voices = 5;
