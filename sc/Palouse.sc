/*
NodeProxy.defaultNumAudio
NodeProxy.defaultNumAudio = value
From superclass: BusPlug
Default number of channels when initializing in audio rate and no specific number is given (default: 2).

NodeProxy.defaultNumControl
NodeProxy.defaultNumControl = value
From superclass: BusPlug
Default number of channels when initializing in control rate and no specific number is given (default: 1).

*/

Palouse {
  var <primes, mixBus, delayBus, server;

  *new { |saver, primePath|
		^super.new.init(saver, primePath)
	}

	init { |svr, primePath|
    server = svr;

    primes = Dictionary.new;
    PathName.new(primePath).entries.do({|e|
      primes[e.fileNameWithoutExtension] = e.fullPath.load
		});

    server.sync;

    ("primes:").postln;
    primes.postln;

    delayBus = Bus.audio(server, 2);
    mixBus = Bus.audio(server, 2);

    server.sync;

    // Global bps (beats-per-second) tempo
    Ndef(\bps, {|bps, lag=0| bps.lag(0) });

    // Mix/Echo
    Ndef(\delay, {|beats=0.1, lag=0.1, decay=3.7|
      var tr = 1/10000;
      var delayTime = (beats / Ndef(\bps).max(0.1)).max(tr).lag(lag);
      var out = In.ar(delayBus.index, 2);
      delayTime = SinOsc.kr(0.01, [0, pi/12], tr, delayTime + tr);
      Out.ar(mixBus, LeakDC.ar(CombC.ar(out, 2, delayTime, decay)));
    });

    Ndef(\mix, {|gain=1, vol=1|
      (In.ar(mixBus, 2) * gain.lag(0.1)).tanh * vol.lag(0.1).max(0).min(1);
    }).play;

    // Routing
    Ndef(\delay).group.moveToHead;
    Ndef(\mix).group.moveToTail;

    // Global ape (arbitraria perplexus enigmus)
    Ndef(\ape, {|ape, lag=0| ape.lag(0); });
  }

  make {|primeName, ndefName, play=false, moveToHead=false|
    var name = ndefName;
    "creating prime Ndef".postln;
    ("ndefName = "++ndefName++" (type "++ndefName.class++")").postln;
    ("primeName = "++primeName++" (type "++primeName.class++")").postln;

    fork {
      //fn.asSynthDef.allControlNames.postln;

      Ndef(name, primes[primeName.asString]);
      Ndef(name).fadeTime = 2;
      //if (play, { Ndef(name).play });

      server.sync;

      Ndef(name).postln;
      Ndef(name).group.postln;
      Ndef(name).numChannels.postln;

    }
  }

  // assume stereo output
  play {|name|
    var nd = Ndef(name);
    ("playing ndef " ++ nd ++ " which has " ++ nd.numChannels ++ " channels").postln;
    if (nd.numChannels == 2, {
      ("playing ndef " ++ nd ++ "as-is").postln;
      nd.play;
    },{
      var fn;
      if (nd.numChannels == 1, {
        ("playing ndef " ++ nd ++ " into panner").postln;
        Ndef((name ++ "_pan").asSymbol, {|pan|
          Pan2.ar(nd, pan);
        }).play;
      },{
        ("playing ndef " ++ nd ++ " into splay").postln;
        Ndef((name ++ "_splay").asSymbol, {|spread|
          Splay.ar(nd, spread);
        }).play;
      });
    });
  }

  jump {|from, to|
    Ndef(from).group.moveAfter(Ndef(to));
  }

  duck {|from, to|
    Ndef(from).group.moveAfter(Ndef(to));
  }

  soar {|name|
    Ndef(name).group.moveToHead;
  }

  sink {|name|
    Ndef(name).group.moveToTail;
  }

  free {|name|
    Ndef(name).free;
  }

  plug{|to, input, from|
    Ndef(to).set(input, Ndef(from));
  }

  setParam {|ndef, param, value|
    Ndef(ndef).set(param, value);
  }

  setParamLag {|ndef, param, lag|
    Ndef(ndef).lag(param, lag);
  }

  trigger {|ndef, amp|
    Ndef(ndef).set(\mul, amp);
    Ndef(ndef).set(\t_trig, 1);
  }

  setBps {|bps|
    Ndef(\bps).set(\bps, bps);
  }

  // useful?
  start {
    Ndef(\start).set(\t_trig, 1);
  }

  queryNodes{
    server.queryAllNodes
  }
}