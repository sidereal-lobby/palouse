--  ____,  __,   __,    ____, 
-- (-(__  (-|   (-|    (-/  \ 
--  ____)  _|_,  _|__,  _\__/,
-- (      (     (      (      

-- cpath tweak for binary import
-- we need this for both json & websockets
-- thanks schollz: 
-- https://github.com/schollz/o-o-o/blob/2de8de7e955f159c43eef98e3a832a8824d9053f/o-o-o.lua#L27
local orig_cpath = package.cpath
if not string.find(orig_cpath,"/home/we/dust/code/palouse/lib/") then
  package.cpath=orig_cpath..";/home/we/dust/code/palouse/lib/?.so"
end

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
loess     = include("lib/loess")
oam       = include("lib/oam")
network   = include("lib/network")
json      = include("lib/json")
history   = include("lib/history")
state     = include("lib/state")
logger    = include("lib/logger")
--p         = include("lib/goodname")
repl      = include("lib/repl") -- if this isn't last, WEIRD THINGS HAPPEN

-- livecode
l                  = loess     -- 10% of earth's land area is covered by loess
l.ape              = s{1}      -- arbitraria perplexus enigmus
l.root             = s{60}     -- root
l.tempo            = s{120}    -- tempo
l.reverb           = s{1}      -- off 1, on 2
l.rev_return_level = s{0.0}    -- db
l.rev_pre_delay    = s{60.0}   -- ms
l.rev_lf_fc        = s{200.0}  -- hz
l.rev_low_time     = s{6.0}    -- seconds
l.rev_mid_time     = s{6.0}    -- seconds
l.rev_hf_damping   = s{6000.0} -- hz
l.delay_beats      = s{3/4}    -- beats
l.delay_decay      = s{5}      -- seconds
l.delay_lag        = s{0.05}   -- seconds

-- clock
params:set("clock_tempo", l.tempo())

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
params:set("reverb",            l.reverb())
params:set("rev_eng_input",     -9.0)   -- dB
params:set("rev_cut_input",     -9.0)   -- dB
params:set("rev_monitor_input", -100.0) -- dB
params:set("rev_tape_input",    -100.0) -- dB
params:set("rev_return_level",  l.rev_return_level())
params:set("rev_pre_delay",     l.rev_pre_delay())
params:set("rev_lf_fc",         l.rev_lf_fc())
params:set("rev_low_time",      l.rev_low_time())
params:set("rev_mid_time",      l.rev_mid_time())
params:set("rev_hf_damping",    l.rev_hf_damping())

function init()
  fn.init()
  fn.load_config()
  clocks.init()
  graphics.init()
  loess.init()
  network.init()
  network.init_clock()

  print("sunrise lasted "..string.format("%.4f", history.get_ts()).." seconds")
  tempo_lattice = lattice:new{}
  tempo_pattern = tempo_lattice:new_pattern{ action = clocks.tempo_action }
  tempo_lattice:start()
  fn.light_bonfire()

  repl.init()
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

function osc.event(path, args, from)
  if path == '/add_model' then
    -- print('add model "'..args[1]..'"')
    state.add_model(args[1])
  else
    print('received an OSC event at path '..path)
    tu.print(args)
    print('')
  end
end

function redraw()
  graphics:render()
end

function cleanup()
  package.cpath = orig_cpath 

  network.cleanup()
  clocks.cleanup()
end
