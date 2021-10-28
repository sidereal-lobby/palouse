{|freq=55, decay=5, mul=1|
  freq = freq.max(0.0001);
  CombN.ar(\in.ar(0!2), 1, freq.reciprocal, decay, mul);
}
