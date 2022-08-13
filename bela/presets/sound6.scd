~presetName = "wood impact + cat";
~primaryBuffers = ~fillNSamples.("wood_hitting", 3, digits: 2);
~secondaryBuffers = ~fillNSamples.("new-cat_var", 9, digits: 2) ++ ~fillNSamples.("cat-scratch_var", 5, digits: 2);
~ampfactor = 9.5.neg;
~ampfactorSecondary = 20.0.neg;
~combFilterDryWet = 0.0;
