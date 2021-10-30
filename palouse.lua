-- palouse

engine.name = 'Palouse'

-- requires (order agnostic)
tu        = require("tabutil")
s         = require("sequins")
lattice   = require("lattice")

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

function init()
  fn.init()
  fn.load_config()
  fn.print("P A L O U S E")
  clocks.init()
  graphics.init()
  stage.init()
  network.init()
  network.init_clock()
  fn.set_default_params()
  redraw_clock_id = clock.run(clocks.redraw_clock)
  fn.light_bonfire()
end

function key(k, z)
  if z == 0 then return end
  if k == 1 then return end
  if k == 2 then fn.rerun() end
  if k == 3 then fn.rerun() end
end

fontsize = 8

function enc(e, d)
  print(e, d)
end

function redraw()
  graphics:render()
end

function cleanup()
  network:cleanup()
end
