local clocks = {}

function clocks.redraw_clock()
  while true do
    if fn.screen_dirty() then
      redraw()
      fn.screen_dirty(false)
    end
    clock.sleep(1 / 15)
  end
end

return clocks