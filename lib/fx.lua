-- compressor settings
params:set("compressor",      2)    -- off 1, on 2
params:set("comp_mix",        0.5)  -- 0.0 - 1.0
params:set("comp_ratio",      4.0)  -- 1.0 - 20.0
params:set("comp_threshold",  -9.0) -- dB
params:set("comp_attack",     5.0)  -- ms
params:set("comp_release",    51.0) -- ms
params:set("comp_pre_gain",   0.0)  -- dB
params:set("comp_post_gain",  9.0)  -- dB

-- reverb settings
params:set("reverb",            p.reverb())
params:set("rev_eng_input",     -9.0)   -- dB
params:set("rev_cut_input",     -9.0)   -- dB
params:set("rev_monitor_input", -100.0) -- dB
params:set("rev_tape_input",    -100.0) -- dB
params:set("rev_return_level",  p.rev_return_level())
params:set("rev_pre_delay",     p.rev_pre_delay())
params:set("rev_lf_fc",         p.rev_lf_fc())
params:set("rev_low_time",      p.rev_low_time())
params:set("rev_mid_time",      p.rev_mid_time())
params:set("rev_hf_damping",    p.rev_hf_damping())