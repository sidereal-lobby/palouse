Engine_Palouse : CroneEngine {
  classvar luaOscPort = 10111;
  var palouse;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    var luaOscAddr = NetAddr("localhost", luaOscPort);

    palouse = Palouse.new(context.server, "/home/we/dust/code/palouse/sc/prime");
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
