-- palouse

include("lib/includes")

function init()
  fn.init()
  fn.load_config()
  fn.print("P A L O U S E")
  clocks.init()
  graphics.init()
  stage.init()
  screen_dirty = true
  redraw_clock_id = clock.run(clocks.redraw_clock)
  fn.light_bonfire()
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