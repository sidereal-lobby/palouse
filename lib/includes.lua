-- sc

engine.name = 'Palouse'

-- requires
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
p         = include("lib/goodname")
json      = include("lib/json")
--p       = include("lib/livecode")
--          include("lib/fx")
