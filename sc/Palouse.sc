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

  createShell {|name|
    fork {
      // create main ndef
      Ndef(name, primes["donk"]);

      // create "channel strip" ndef
      Ndef((name ++ \Strip).asSymbol, {
        |level=1, pan=0, send_delay=0, lag=1|
        var delayOut;
        var out = \in.ar(0 ! 2);

        //out = LeakDC.ar(out, mul: volume.lag(lag));
        out = Balance2.ar(out[0], out[1], pan.lag(lag)).tanh;

        Out.ar(delayBus.index, out * send_delay.lag(lag));
        Out.ar(mixBus.index, out * level.lag(lag));
      });

      // set main ndef fade time
      Ndef(name).fadeTime = 2;

      // plug main ndef into strip ndef
      Ndef((name ++ \Strip).asSymbol) <<>.in Ndef(name);

      server.sync;

      // move to head (so that they can properly feed buses)
      Ndef((name ++ \Strip).asSymbol).group.moveToHead;
      Ndef((name).asSymbol).group.moveToHead;
    }
  }

  freeShell {|name|
    // free main ndef
    Ndef((name ++ \Strip).asSymbol).free;

    // free "channel strip" ndef
    Ndef((name ++ \Strip).asSymbol).free;
  }

  setShellParam {|shell, param, value|
    Ndef(shell).set(param, value);
  }

  setShellStripParam {|shell, param, value|
    Ndef((shell ++ "Strip").asSymbol).set(param, value);
  }

  setMixParam {|param, value|
    Ndef(\mix).set(param, value);
  }

  setDelayParam {|param, value|
    Ndef(\delay).set(param, value);
  }

  triggerShell {|shell, velocity|
    Ndef(shell.asSymbol).set(\volume, velocity);
    Ndef(shell.asSymbol).set(\t_trig, 1);
  }

  setBps{|bps|
    Ndef(\bps).set(\bps, bps);
  }
}