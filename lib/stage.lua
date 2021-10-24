--[[

Stage
#####


]]

local stage = {}

function stage.init()
  stage.root_note = 60
  stage.lattices = {}
end

function stage:get_root_note()
  return self.root_note
end

function stage:add_lattice(id, l)
  self.lattices[id] = l
  self.lattices[id]:start()
end

function stage:destroy_lattice(id)
  self.lattices[id]:destroy()
  self.lattices[id] = nil
end

function stage:get_lattice(id)
  return self.lattices[id]
end

return stage