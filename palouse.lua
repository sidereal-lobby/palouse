-- palouse

include("lib/includes")

function init()
  fn.print("P A L O U S E")
  graphics.init()
  screen_dirty = true
  redraw_clock_id = clock.run(clocks.redraw_clock)
  fn.load_config()
  fn.light_bonfire()
end

function key(k, z)
  if z == 0 then return end
  if k == 1 then return end
  if k == 2 then graphics:peek() return end
  if k == 3 then graphics:poke() end
  fn.screen_dirty(true)
end

fontsize = 8

function enc(e, d)
  print(e, d)
end

function redraw()
  -- graphics:draw_home()
  graphics:draw_splash()
end