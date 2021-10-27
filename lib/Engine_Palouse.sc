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
      Ndef(name, {|t_trig=0, note=48, volume=1, mod=0, lag=0|
        var env = t_trig.lagud(0, 0.2) * volume;
        note = note.lag(lag);
        mod = mod.lag(lag);
        SinOscFB.ar((note).midicps, mod, env) ! 2;
      });

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

Engine_Palouse : CroneEngine {
  classvar luaOscPort = 10111;
  var palouse;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    var luaOscAddr = NetAddr("localhost", luaOscPort);

    palouse = Palouse.new(context.server, "/home/we/dust/code/palouse/lib/prime");
    palouse.primes.keys.do({ arg name;
			("sending name: " ++ name).postln;
			luaOscAddr.sendMsg("/add_prime", name);
		});

    this.addCommand("bps", "f", {|msg|
      palouse.setBps(msg[1]);
    });

    this.addCommand("bpm", "f", {|msg|
      palouse.setBps(msg[1]/60);
    });

    this.addCommand("create", "s", {|msg|
      palouse.createShell(msg[1]) });

    this.addCommand("free", "s", {|msg|
      palouse.freeShell(msg[1]) });

    this.addCommand("trig", "sf", {|msg|
      palouse.triggerShell(msg[1], msg[2]) });

    [\note, \mod, \lag, \volume].do({|cmd|
      this.addCommand(cmd, "sf", {|msg|
        palouse.setShellParam(msg[1], cmd, msg[2])
      })
    });

    [\level, \pan, \lag, \send_delay].do({|cmd|
      this.addCommand(cmd, "sf", {|msg|
        palouse.setShellStripParam(msg[1], cmd, msg[2]);
      });
    });

    [\gain, \vol].do({|cmd|
      this.addCommand(\mix_ ++ cmd, "f", {|msg|
        palouse.setMixParam(cmd, msg[1]);
      });
    });

    [\beats, \lag, \decay].do({|cmd|
      this.addCommand(\delay_ ++ cmd, "f", {|msg|
        palouse.setDelayParam(cmd, msg[1]);
      });
    });

    this.addCommand("eval", "s", {|msg|
      try {
        msg[1].asString.compile.value;
      } { |error|
        ("error evaluating:\n```"++msg[1]++
          "```\n----\n"++error++"\n----").postln;
      }
    });

    this.addCommand("ape", "f", {|msg|
      Ndef(\ape).set(\ape, msg[1]);
    });
    // done commands
  }

  free {
    Ndef.clear(0);
  }
}
