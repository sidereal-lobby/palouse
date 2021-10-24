--[[

OAM Arbitrary Model
###################

The Way that can be walked is not the eternal Way.
The name that can be named is not the eternal name.
The nameless is the beginning of Heaven and Earth.
The named is the mother of all things.

Therefore:
Free from desire you see the mystery.
Full of desire you see the manifestations.
These two have the same origin but differ in name.
That is the secret,
The secret of secrets,
The gate to all mysteries.
]]

local oam = {}

function oam:new(data)
  local o = setmetatable({}, { __index = oam })
  o.id = fn.id("oam")
  o.exegesis = "The gate to all mysteries."
  o.name = "Nameless" -- names are special
  o.major_version = 0
  o.minor_version = 0
  o.patch_version = 1
  o.data = data
  o.born = os.time() -- note: each ape norns speaks of different times
  o.is_ancient = false
  o.is_enabled = true
  return o
end

-- factory method to make an "ancient"
function oam:make_ancient(data)
  local ancient = self:new(data)
  ancient.is_ancient = true
  ancient.name = data.name
  ancient.del = s{0}    -- delay send: -1 - 1 (or more, to clip)
  ancient.lag = s{0}    -- channel strip lag: 0 - +inf (seconds)
  ancient.lvl = s{1}    -- volume: -1 - 1 (or more, to clip)
  ancient.mod = s{0}    -- modulation: 0 - 100
  ancient.mtr = s{1}    -- meter: 1 - n
  ancient.nte = s{0}    -- note: semitones from v.root
  ancient.pan = s{0}    -- pan: -1 - 1
  ancient.tpz = s{0}    -- transpose: just this voice
  ancient.trg = s{1}    -- trigger: 0 or 1
  ancient.vel = s{100}  -- velocity: 0 - 100
  local ancient_lattice = lattice:new{}
  ancient.pattern = ancient_lattice:new_pattern{
    action = function(t)
      ancient:step(t)
    end
  }
  stage:add_lattice(ancient.name, ancient_lattice)
  return ancient
end

function oam:step(t)
  -- print("oam step", t)
  if self.is_enabled then
    -- print("engine.note", self:get_name(), stage:get_root_note() + self:get_tpz() + self:get_nte())
      -- engine.note(self:get_name(), stage:get_root_note() + self:get_tpz() + self:get_nte())
    -- print("engine.mod", self:get_name(), self:get_mod_float())
      -- engine.mod(self:get_name(), self:get_mod_float())
    if self:get_trg() == 1 then
      -- print("engine.trig", self:get_name(), self:get_vel_float())
        -- engine.trig(self:get_name(), self:get_vel_float())
      -- print("todo: graphics:trigger(self:get_name())")
    end
  end
end

function oam:get_name() return self.name end

-- all sequins
function oam:get_del() return self.del() end
function oam:get_lag() return self.lag() end
function oam:get_lvl() return self.lvl() end
function oam:get_mod() return self.mod() end
function oam:get_mtr() return self.mtr() end
function oam:get_nte() return self.nte() end
function oam:get_pan() return self.pan() end
function oam:get_tpz() return self.tpz() end
function oam:get_trg() return self.trg() end

-- helpers
function oam:get_mod_float()
  return util.linlin(0, 100, 0.0, 1.0, self:get_mod())
end

function oam:get_vel_float()
  return util.linlin(0, 100, 0.0, 1.0, self:get_vel())
end

-- utilities
function oam:report()
  print("")
    print("~~~~~~~.~~~~~~~.~~~~~~~.~~~~~~~.")
    tu.print(self)
    print("~~~~~~~.~~~~~~~.~~~~~~~.~~~~~~~.")
  print("")
end

-- LIVECODE API

-- get the lattice
function oam:l()
  if self.is_ancient then
    return stage:get_lattice(self.name)
  else
    fn.print("This OAM is not an ancient.")
  end
end

-- get the pattern
function oam:p()
  if self.is_ancient then
    return self.pattern
  else
    fn.print("This OAM is not an ancient.")
  end
end

return oam