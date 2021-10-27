local livecode            = {}        -- protect the palouse

-- Music
livecode.root             = s{60}     -- root
livecode.tempo            = s{120}    -- tempo

-- ?
livecode.ape              = s{1}      -- ape

-- fx
livecode.reverb           = s{1}      -- off 1, on 2
livecode.rev_return_level = s{0.0}    -- db
livecode.rev_pre_delay    = s{60.0}   -- ms
livecode.rev_lf_fc        = s{200.0}  -- hz
livecode.rev_low_time     = s{6.0}    -- seconds
livecode.rev_mid_time     = s{6.0}    -- seconds
livecode.rev_hf_damping   = s{6000.0} -- hz
livecode.delay_beats      = s{3/4}    -- beats
livecode.delay_decay      = s{5}      -- seconds
livecode.delay_lag        = s{0.05}   -- seconds

return livecode
