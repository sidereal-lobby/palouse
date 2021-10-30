--[[

Loess
#####

Loess is an aeolian (windborne) sediment, defined as an accumulation of 20%
or less of clay and a balance of roughly equal parts sand and silt (with a
typical grain size from 20 to 50 micrometers),[3][4] often loosely cemented
by calcium carbonate. It is usually homogeneous and highly porous and is
traversed by vertical capillaries that permit the sediment to fracture and
form vertical bluffs.

]]

local loess = {}

function loess.init()
  loess.ancients = {}
  loess.ancients_names = {}
  loess.lattices = {}
end

function loess:is_ancient(id)
  local out = false
  for k, v in pairs(self.ancients) do
    if k == id then
      out = true
    end
  end
  return out
end

function loess:is_ancient_name(name)
  local out = false
  for ancient_name, ancient_id in pairs(self.ancients_names) do
    if ancient_name == name then
      out = true
    end
  end
  return out
end

function loess:add_ancient(ancient)
  self.ancients[ancient.id] = ancient
  self.ancients_names[ancient.name] = ancient.id
  l[ancient.name] = ancient
end

function loess:destroy_ancient(id)
  local n = self.ancients[id].name
  self.ancients[id] = nil
  self.ancients_names[n] = nil
  l[n] = nil
end

function loess:get_ancient_by_name(name)
  return self.ancients[self.ancients_names[name]]
end

function loess:add_lattice(id, l)
  self.lattices[id] = l
  self.lattices[id]:start()
end

function loess:destroy_lattice(id)
  self.lattices[id]:destroy()
  self.lattices[id] = nil
end

function loess:get_lattice(id)
  return self.lattices[id]
end

return loess