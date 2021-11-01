{|t_trig=0, attack=0.01, decay=0.7, curve=(-4), levelScale=1, levelBias=0,
timeScale=1|
  var spec = Env.perc(attack, decay, 1, curve);
  EnvGen.kr(spec, t_trig, levelScale, levelBias, timeScale);
}
