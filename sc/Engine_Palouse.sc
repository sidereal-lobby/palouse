Engine_Palouse : CroneEngine {
  classvar luaOscPort = 10111;
  classvar fnDir = "/home/we/dust/code/palouse/sc/prime";
  var palouse;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    var luaOscAddr = NetAddr("localhost", luaOscPort);

    palouse = Palouse.new(context.server, fnDir);
    palouse.primes.keys.do({ arg name;
			("sending name: " ++ name).postln;
			luaOscAddr.sendMsg("/add_prime", name);
		});


    // LIFECYCLE
    this.addCommand("make", "ss",
      {|msg| palouse.make(msg[1], msg[2]) });

    this.addCommand("free", "s",
      {|msg| palouse.free(msg[1]) });

    this.addCommand("play", "s",
      {|msg| palouse.play(msg[1]) });


    // ORDER
    this.addCommand("jump", "ss",
      {|msg| palouse.jump(msg[1], msg[2]) });

    this.addCommand("duck", "ss",
      {|msg| palouse.duck(msg[1], msg[2]) });

    this.addCommand("soar", "s",
      {|msg| palouse.soar(msg[1]) });

    this.addCommand("sink", "s",
      {|msg| palouse.sink(msg[1]) });


    // RELATIONSHIPS
    this.addCommand("plug", "sss",
      {|msg| palouse.plug(msg[1], msg[2], msg[3]) });


    // BEHAVIOR
    this.addCommand("set", "ssf",
      {|msg| palouse.setParam(msg[1], msg[2], msg[3]) });

    this.addCommand("trig", "sf",
      {|msg| palouse.trigger(msg[1], msg[2]) });

    this.addCommand("fade", "sf",
      {|msg| palouse.setFade(msg[1], msg[2]) });

    this.addCommand("lag", "ssf",
      {|msg| palouse.setParamLag(msg[1], msg[2], msg[3]) });


    // ENVIRONMENT
    this.addCommand("bps", "f",
      {|msg| palouse.setBps(msg[1]) });


    // (obsolete)
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


    // debugging
    this.addCommand("query_nodes", "", {
      palouse.queryNodes });

    this.addCommand("ape", "f", {|msg|
      Ndef(\ape).set(\ape, msg[1]);
    });

    /*this.addCommand("eval", "s", {|msg| // YIKES
      try {
        msg[1].asString.compile.value;
      } { |error|
        ("error evaluating:\n```"++msg[1]++
          "```\n----\n"++error++"\n----").postln;
      }
    });*/
    // done commands
  }

  free {
    Ndef.clear(0);
  }
}
