--  ____,  __,   __,    ____, 
-- (-(__  (-|   (-|    (-/  \ 
--  ____)  _|_,  _|__,  _\__/,
-- (      (     (      (      

engine.name = "Palouse"

-- requires (order agnostic)
tabutil   = require("tabutil")
tu        = tabutil
sequins   = require("sequins")
s         = sequins
lattice   = require("lattice")
l         = lattice

-- includes (order matters)
clocks    = include("lib/clocks")
fn        = include("lib/fn")
graphics  = include("lib/graphics")
metadata  = include("lib/metadata")
stage     = include("lib/stage")
oam       = include("lib/oam")
network   = include("lib/network")

-- livecode
p                  = {}        -- protect the palouse
p.ape              = s{1}      -- ape
p.root             = s{60}     -- root
p.tempo            = s{120}    -- tempo
p.reverb           = s{1}      -- off 1, on 2
p.rev_return_level = s{0.0}    -- db
p.rev_pre_delay    = s{60.0}   -- ms
p.rev_lf_fc        = s{200.0}  -- hz
p.rev_low_time     = s{6.0}    -- seconds
p.rev_mid_time     = s{6.0}    -- seconds
p.rev_hf_damping   = s{6000.0} -- hz
p.delay_beats      = s{3/4}    -- beats
p.delay_decay      = s{5}      -- seconds
p.delay_lag        = s{0.05}   -- seconds

-- clock
params:set("clock_tempo", p.tempo())

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

function init()
  fn.init()
  fn.load_config()
  clocks.init()
  graphics.init()
  stage.init()
  network.init()
  network.init_clock()
  redraw_clock_id = clock.run(clocks.redraw_clock)
  tempo_lattice = lattice:new{}
  tempo_pattern = tempo_lattice:new_pattern{ action = fn.tempo_action }
  tempo_lattice:start()
  fn.light_bonfire()
end

function key(k, z)
  if z == 0 then return end
  if k == 1 then return end
  if k == 2 then fn.rerun() end
  if k == 3 then fn.rerun() end
end

function enc(e, d)
  print(e, d)
end

function redraw()
  graphics:render()
end

function cleanup()
  network:cleanup()
end
