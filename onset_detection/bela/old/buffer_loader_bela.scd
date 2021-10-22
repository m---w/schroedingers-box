//sound1
~sound1var1 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var01.wav", channels:1);
~sound1var2 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var02.wav", channels:1);
~sound1var3 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var03.wav", channels:1);
~sound1var4 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var04.wav", channels:1);
~sound1var5 = Buffer.readChannel(s, "./sounds/atakes_vasi_ixeion_me_kleidi_var05.wav", channels:1);

//sound2
~sound2var1 = Buffer.readChannel(s, "./sounds/kagelo01.wav", channels:1);
~sound2var2 = Buffer.readChannel(s, "./sounds/kagelo02.wav", channels:1);

//sound3
~sound3var1 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var1.wav", channels:1);
~sound3var2 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var2.wav", channels:1);
~sound3var3 = Buffer.readChannel(s, "./sounds/metaliko_kouti_diafores _attakes_var3.wav", channels:1);

//sound4
~sound4var1 = Buffer.readChannel(s, "./sounds/timpani_bends1_var1.wav", channels:1);
~sound4var2 = Buffer.readChannel(s, "./sounds/timpani_bends1_var2.wav", channels:1);
~sound4var3 = Buffer.readChannel(s, "./sounds/timpani_bends1_var3.wav", channels:1);
~sound4var4 = Buffer.readChannel(s, "./sounds/timpani_bends1_var4.wav", channels:1);
~sound4var5 = Buffer.readChannel(s, "./sounds/timpani_bends1_var5.wav", channels:1);
~sound4var6 = Buffer.readChannel(s, "./sounds/timpani_bends1_var6.wav", channels:1);

//sound5
~sound5var1 = Buffer.readChannel(s, "./sounds/35dogtoy_var1.wav", channels:1);
~sound5var2 = Buffer.readChannel(s, "./sounds/35dogtoy_var2.wav", channels:1);

//~sound = [~sound3var1, ~sound3var2, ~sound3var3];// ~sound1var4, ~sound1var5]

//play{PlayBuf.ar(2, bufnum: ~sound[2])}