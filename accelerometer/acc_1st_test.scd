//bela acc 1st test


SynthDef("help-AnalogIn",{ arg out=7;
    //x
    Out.ar(6,
      SinOsc.ar( AnalogIn.ar( 0 ).exprange( 200, 5000 ), 0, 0.1 )
    );
    //y
    Out.ar(7,
      Saw.ar( AnalogIn.ar( 1 ).exprange( 200, 5000 ), 0.05 )
    );
    //z
    Out.ar(6, VarSaw.ar( AnalogIn.ar( 2 ).exprange( 400, 10000 ), mul:0.1 )!2)
}).play;
