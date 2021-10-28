{|t_trig=0, note=48, volume=1, mod=0, lag=0|
  var env = t_trig.lagud(0, 0.2) * volume;
  note = note.lag(lag);
  mod = mod.lag(lag);
  SinOscFB.ar((note).midicps, mod, env) ! 2;
}
