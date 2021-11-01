local clocks = {}

function clocks.init()
  clocks.redraw_frame = 0
  clocks.redraw_clock_id = clock.run(clocks.redraw_clock)
end

function clocks.redraw_clock()
  while true do
    clocks.redraw_frame = clocks.redraw_frame + 1
    redraw()
    screen.ping()
    clock.sleep(1 / 15)
  end
end

function clocks.cleanup()
  clock.cancel(clocks.redraw_clock_id)
end

function clocks.tempo_action()
  -- need to cache these because sequins change on each access
  root_cache = loess.root()
  tempo_cache = loess.tempo()
  params:set("clock_tempo", tempo_cache)
  engine.bps(tempo_cache/60)
end

return clocks
