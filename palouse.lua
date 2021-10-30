-- palouse
dawn = util.time()

-- cpath tweak for binary import
-- we need this for both json & websockets
-- thanks schollz: 
-- https://github.com/schollz/o-o-o/blob/2de8de7e955f159c43eef98e3a832a8824d9053f/o-o-o.lua#L27
local orig_cpath = package.cpath
if not string.find(orig_cpath,"/home/we/dust/code/palouse/lib/") then
  package.cpath=orig_cpath..";/home/we/dust/code/palouse/lib/?.so"
end

include("lib/includes")

function init()
  fn.init()
  fn.load_config()
  fn.print("P A L O U S E")
  clocks.init()
  graphics.init()
  stage.init()
  network.init()
  network.init_clock()

  screen_dirty = true
  --fn.light_bonfire() -- DON'T LIGHT MY FIRE!! - Otoboke Beaver

  print("sunrise lasted "..string.format("%.4f", util.time()-dawn).." seconds")
end

function key(k, z)
  if z == 0 then return end
  if k == 1 then return end
  if k == 2 then fn.rerun() end
  if k == 3 then fn.rerun() end
  fn.screen_dirty(true)
end

fontsize = 8

function enc(e, d)
  print(e, d)
end

function redraw()
  graphics:render()
end

function cleanup()
  package.cpath = orig_cpath 

  network.cleanup()
  clocks.cleanup()
end
