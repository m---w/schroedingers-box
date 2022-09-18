/*
Big Red Button
connected to DigitalIn on Bela
for preset increment
*/



~participantID = 0;


// initialisation
// has to be -1 => array (0..55)
// first press is 0 - first sound
~presetNr = -1;


// presets selected for the presentation
~experimentOrder =
// -------- start -----------
[
	[
		16, // finger snap
		17, // plastic container
		18, // spray
		19, // bell (physical model)
		20, // wood impact (toing) | secondary: cheering
		23, // book page chattering
		24, // fan scissors
		25, // fan rattle
		26, // Davor spring wire
		27, // my toaster
		28, // cough
		29, // music stand rattle
		30, // fan wire rattle
		32, // impact | cartoon outcome (toing - crash)
		33, // chaotic drop => greyhole
		34, // water | outcome: water
		36, // metal plate rattling at KHG
		38, // axe
		39, // match strike | outcome: match light
		40, // cage bars | secondary: lion
		41, // sk8board
		42, // thermo | secondary: balloons
		43, // stapler | secondary: pin drop
		44, // stapler rattling feedback
		45, // noodles metallic top | secondary: noodles shake
		46, // aluminium toing overtones
		47, // metallic box with nuts inside
		48, // plastic bag pop | various plastic bag feedback
		49, // click | secondary: boiler
		50, // coolness (artificial sound)
		51, // popping | secondary: party horn
		52, // impact | electric toy duck
		53, // aluminium toing | secondary nail drop on table
		54, // plastic bag crumbling sound
		55, // wood crack
		57, // bin top bouncing
		58, // stone drop
		59, // leaves kick
		60, // "tum" wood box
		61, // big metal plate
		62, // laser
		66, // vintage red box
		67, // container long
		80, // cash register
		82, // ouch!
		83, // bin restmuel | outcome: bin top bouncing
		2, // metallic rail
		3, // metallic box
		4, // tympani
		5, // squeaky toy
		6, // wood impact | secondary: cat
		7, // wooden door kick
		10, // bottle impact | outcome: bottle break
		11, // aluminium can, can opening
		12, // harpsi
		13, // water glass
		15, // thesis (artificial)
	],
];

// post the order FYI
("experimentOrder:"+~experimentOrder).postln;


// NOTES:

// metal: 1, 46
// funny: 5, 82
// outcome demonstration: 10, 83
// secondary demonstration: 6
// cool: 33, 34, 26

// selection of simple metallic sounds:
// 1, 2, 3, 26, 36, 42, 47, 61, 62, 63

~bigRedButtonFunc = {
	~presetNr = ~presetNr + 1; // increment to next preset (will be loaded next time)
	~presetNr = ~presetNr.wrap(0, ~experimentOrder.flat.size); // wrap presets around

	// participant_id at which sample
	~preset = ~experimentOrder[~participantID].at(~presetNr.max(0)); // get current preset number (clip at 0)
	("preset:"+~preset).postln; // post current preset
	// o.sendMsg('/preset', next); // send preset to the synth (Bela) via OSC

	// e[\preset] = next; // set local variable, too
	// {~gui.upd;}.defer; // update GUI


};