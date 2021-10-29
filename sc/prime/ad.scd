{|t_trig=0, attack=0.01, decay=0.7, curve=-4, levelScale, levelBias, timeScale|
  EnvGen.kr(Env.perc(attack, decay, 1, curve),
    t_trig, levelScale, levelBias, timeScale);
}