/*
	Schroedinger's Box
	Install patch (run this first to install Quarks on Bela
	2022 Marian Weger
*/

"Starting install ... ".postln;

~path = PathName(thisProcess.nowExecutingPath).pathOnly; // current path

// check if all required quarks are installed, if not install them
if(Quarks.isInstalled("ddwVoicer").not, {
	"Installing Quarks ... ".postln;
	Quarks.addFolder(~path+/+"quarks");
	// quarks needed for Voicer
	Quarks.install("crucial-library"); // dependency of ddwCommon
	Quarks.install("ddwCommon"); // dependency of ddwVoicer
	Quarks.install("ddwGUIEnhancements"); // dependency of ddwVoicer
	Quarks.install("ddwVoicer"); // needed for sclang-logic
	"Installing Quarks ... done.".postln;
});

"DONE install.".postln;
