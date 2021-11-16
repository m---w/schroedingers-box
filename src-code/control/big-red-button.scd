// initialize the midi client
MIDIClient.init;

// connect all the possible inputs
MIDIIn.connectAll;


MIDIdef.cc(\bigredbutton, {
	| ...args|
	
	args.postln;
	
	
}, 16); // match cc 1


//:
f = { | in = 0 |
	var temp, arr, val, suf;
	arr = in;
	suf = Pn(Pshuf(in, 1), inf).asStream;
	temp = suf.next;
	if(temp == ~last){
		arr = in;
		val = arr.remove(temp);
		arr.postln;
		temp = arr.choose;
		arr = arr.add(val);
	};
	~last = temp;
	temp;
};

//:
n = NetAddr("192.168.185.50", 57120);
//:
n.sendMsg('/soundpick/2', \sam_num, f.((1..20)));
//:

OSCdef(\test, {
	| ...args |
	args.postln;
}, '/soundpick/2')




//: latin square sound selection logic
// initial function
l = {
	| participants, n |
	var arr, calc, counter, temp, tempn, finale;
	tempn = n;
	counter = 1;
	arr = (1..n);
	finale = Array(participants+100);
	tempn = participants;
	participants.do{
		tempn = tempn - 1;
		temp = arr.rotate(tempn);
		finale = finale.add(temp);
		counter = counter + 1;
		//temp.postln;
	};
	finale.postln;
	~order = finale;
};

//: evaluate
//1st arg participants, 2nd object sum
//54 sounds (MW-PhD)
l.(4,5)
//global access
~order[1];

m = Matrix.with(~order);
m.postmln;
//:




//logic
a = (1..4)
b = (1..4).rotate(-1)
c = (1..4).rotate(-2)
d = (1..4).rotate(-3)

[1, 2, 3, 4, 5].rotate(1).postln;
[1, 2, 3, 4, 5].rotate(-1).postln;
[1, 2, 3, 4, 5].rotate(3).postln;

