// =====================================================================
// SuperCollider Workspace
// =====================================================================

// NO DUPS!
//: This worx
p = [1,2,3];
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
f.value(~sound);

//:
play{PlayBuf.ar(1, bufnum:~sound)}
//:


