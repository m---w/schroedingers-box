~sound1 = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/exp2__variant_1__metallicity_2__rigidity_1__tenuity_1__decay_2.wav", channels: 0);
~sound2 = Buffer.readChannel(s, ~path+/+"./sounds_preprocessed/exp2__variant_2__metallicity_2__rigidity_1__tenuity_1__decay_2.wav", channels: 0);

~sound = [~sound1, ~sound2];

~addsound = false;
~outcome = false;
~voices = 2;
~ampfactor = 8.0;
~ampfactorcat = inf.neg;


~presetName = "synthetic gold plate";