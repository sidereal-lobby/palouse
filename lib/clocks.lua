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

function clocks.tempo_action()
  -- need to cache these because sequins change on each access
  root_cache = p.root()
  tempo_cache = p.tempo()
  params:set("clock_tempo", tempo_cache)
  engine.bpm(tempo_cache)
end

return clocks