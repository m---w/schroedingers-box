// =====================================================================
// SuperCollider Workspace
// =====================================================================

Pn(scramble[0,2,3])

//:

~newID = 0; // reset sample ID counter
~n = 5; // number of samples
// create n urns where always one of the 5 is missing (all combinations)
~urn = n.collect{|i| 
	var foo = (0..n-1);
	foo.takeAt(i);
	foo;
};
~newID = ~urn[~newID][(n-1).rand]

//:

f = {
	| b = 0, l = 0 | var tempin, here, temper, result;
	here = (0..b.size).choose;
	temper = b.slotKey(here);
	tempin = b[here];
	if(tempin == ~temp){temper = b.takeAt(temper); result = b};
	~temp = tempin;
	[result, ~temp];
	//temper;
};
//:
f.value(p,p.size)


//:
p = [1,2,3]

p.slotAt(1)
p.size
