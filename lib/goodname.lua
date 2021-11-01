local g = {}

local fns = {}
local ndefs = {}

-- TODO:
-- [ ] immediate history recall (i.e. "bring me up to speed")
-- [ ] fluent API: .draw("s").freq(400)
-- [ ] better logging
-- [ ] low/high -> mul/add
-- [ ] list of available "primes" (I dislike this name)
-- [x] autosave history to JSON

print("hello my name is good name and that is a GOOD NAME")

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

-- TODO: do literally anything, RECORD IT


local wave = function()
  print("waved.")
end

-- a "shell" is like a placeholder Ndef
-- like what we did in FCV
function create_shell(name)
  engine.create_shell(name)
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

local plug = function (receiver, input, sender)
  if ndefs[receiver] == nil then
    print("receiver "..receiver.." not found...") 
    return
  elseif ndefs[sender] == nil then
    print("sender "..sender.." not found...") 
    return
  end

  engine.plug(receiver, input, sender)

  ndefs[sender].outs = { rx=receiver, i=input }
  ndefs[receiver].ins[input] = sender

  print("plugged "..sender.." into "..receiver.."'s "..input..".")
end

-- moved to repl
--expose(draw, "draw")
--expose_engine("set")
--expose_engine("play")

--expose(list_events, "list_events")
expose(play_by_index, "play_event")
expose(wave, "wave")
expose(redraw, "redraw")
expose(plug, "plug")
--expose_engine("create_prime") -- hail? draw?
expose_engine("lag")
expose_engine("free")
--expose_engine("plug")

return g
