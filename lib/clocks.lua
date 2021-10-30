local clocks = {}

function clocks.init()
  clocks.redraw_frame = 0
end

function clocks.redraw_clock()
  while true do
    clocks.redraw_frame = clocks.redraw_frame + 1
    redraw()
    screen.ping()
    clock.sleep(1 / 15)
  end
end

return clocks