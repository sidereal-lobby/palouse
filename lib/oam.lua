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
  o.data = data -- store any arbitrary data
  o.born = os.time() -- note: each ape norns speaks of different times
  o.is_ancient = false
  o.is_enabled = true
  return o
end

-- factory method to make more complex oams
-- for now it only makes "ancients"
function oam:make(name, data)
  -- if the ancient already exists, just return it
  if loess:is_ancient_name(name) then 
    return loess:get_ancient_by_name(name)
  else
    local ancient = self:new(data)  -- arbitrary data is always welcome in the oam
    ancient.name = name -- know thy true name
    ancient.is_ancient = true -- eons pass
    ancient.del = data.del ~= nil and data.del or s{0} -- delay send: -1 - 1 (or more, to clip)
    ancient.lag = data.lag ~= nil and data.lag or s{0} -- channel strip lag: 0 - +inf (seconds)
    ancient.lvl = data.lvl ~= nil and data.lvl or s{1} -- volume: -1 - 1 (or more, to clip)
    ancient.mod = data.mod ~= nil and data.mod or s{0} -- modulation: 0 - 100
    ancient.mtr = data.mtr ~= nil and data.mtr or s{1} -- meter: 1 - n
    ancient.div = data.div ~= nil and data.div or s{.25} -- division: .25 - n
    ancient.nte = data.nte ~= nil and data.nte or s{0} -- note: semitones from v.root
    ancient.pan = data.pan ~= nil and data.pan or s{0} -- pan: -1 - 1
    ancient.tpz = data.tpz ~= nil and data.tpz or s{0} -- transpose: just this voice
    ancient.trg = data.trg ~= nil and data.trg or s{1} -- trigger: 0 or 1
    ancient.vel = data.vel ~= nil and data.vel or s{100} -- velocity: 0 - 100
    ancient.print_step = data.print_step ~= nil and true or false -- print each step
    local ancient_lattice = lattice:new{}
    ancient.pattern = ancient_lattice:new_pattern{ action = function(t) ancient:step(t) end }
    loess:add_ancient(ancient)
    loess:add_lattice(ancient.name, ancient_lattice)
    return ancient
  end
end

function oam:step(t)
  self:l():set_meter(self:get_mtr())
  self:p():set_division(self:get_div())
  if self.is_enabled then
    if self.print_step then
      print(self.name, "div: " .. self:p().division, "ppqn stamp: " .. t)
    end
    engine.note(self:get_name(), root_cache + self:get_tpz() + self:get_nte())
    engine.mod(self:get_name(), self:get_mod_float())
    if self:get_trg() == 1 then
      engine.trig(self:get_name(), self:get_vel_float())
    end
  end
end

function oam:get_name() return
  self.name
end

function oam:toggle()
  self.is_enabled = not self.is_enabled
end

function oam:disable()
  self.is_enabled = false
end

function oam:enable()
  self.is_enabled = true
end

-- all sequins
function oam:get_del() return self.del() end
function oam:get_div() return self.div() end
function oam:get_lag() return self.lag() end
function oam:get_lvl() return self.lvl() end
function oam:get_mod() return self.mod() end
function oam:get_mtr() return self.mtr() end
function oam:get_nte() return self.nte() end
function oam:get_pan() return self.pan() end
function oam:get_tpz() return self.tpz() end
function oam:get_trg() return self.trg() end
function oam:get_vel() return self.vel() end

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
    return loess:get_lattice(self.name)
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