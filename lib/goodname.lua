local g = {}

local fns = {}
local ndefs = {}

-- TODO:
-- [ ] immediate history recall (i.e. "bring me up to speed")
-- [ ] *, +  -> mul, add
-- [ ] low/high -> mul/add
-- [x] list of available "primes" (I dislike this name)
-- [x] fluent API: .draw("s").freq(400)
-- [x] autosave history to JSON

-- [0] better logging (this is too vague, refine objectively)

print("hello my name is good name and that is a GOOD NAME")

-- TODO: move to fn
function join(list, sep)
  if not sep then sep = ", " end

  local str = ""
  for i=1,#list do
    str = str .. list[i]
    if i ~= #list then
      str = str .. sep
    end
  end

  return str
end

function expose(fn, name, redef)
  if fn == nil then 
    print("dude where's the function?")
    return
  elseif g[name] and not redef then 
    print(name.." already exposed! force redefinition with redef=true")
  else
    local dbug = debug.getinfo(fn)
    print("expose function '"..name..
      "' ("..dbug.nparams.." args)")
    fns[name] = fn -- for replay
    g[name] = function (...)
      fn(...)
      local args = table.pack(...)
      history.record_event(name, args)
    end
  end
end

function expose_engine(cmd_name, api_name)
  local cmd = engine.commands[cmd_name]
  if not cmd then 
    print("engine has no command '"..cmd_name.."'")
    return
  else
    if api_name == nil then
      api_name = cmd_name
    end
    print("expose engine command '"..cmd_name..
      "' ("..#cmd.fmt.." args: "..cmd.fmt..")")
    fns[api_name] = cmd.func -- for replay
    g[api_name] = function (...)
      -- TODO: set defaults of cmd.fmt 
      --       i.e. s -> "", i => 0, etc.
      cmd.func(...)
      local args = table.pack(...)
      tu.print(args)
      history.record_event(cmd_name, args)
    end
  end
end

-- move these 2 to REPL
local wave = function()
  print("waved.")
end

local redraw = function (ndef_name)
  local ndef = ndefs[ndef_name]
  if not ndef then
    print("no ndef named '"..ndef_name.."!")
    return
  end
  engine.create_prime(ndef.fn_name, ndef_name)
  print("drew a(n) '"..fn_name.."' (#"..index..") named '"..ndef_name.."'.")
end

-- not sure what to do with this
function create_shell(name)
  engine.create_shell(name)
end


-- moved to repl
--expose(draw, "draw")
--expose_engine("set")
--expose_engine("play")
--expose_engine("plug")
--expose(plug, "plug")

--expose(list_events, "list_events")
expose(play_by_index, "play_event")
expose(wave, "wave")
expose(redraw, "redraw")
expose_engine("lag")
expose_engine("free")

return g
