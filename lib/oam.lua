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

function oam.new(data)
  local o = setmetatable({}, { __index = o })
  o.exegesis = "The gate to all mysteries."
  o.major_version = 0
  o.minor_version = 0
  o.patch_version = 1
  o.data = data
  o.born = os.time() -- note: each ape norns speaks of different times
  return o
end

return oam