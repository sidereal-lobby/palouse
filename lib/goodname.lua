local g = {}

local dawn_file = "/home/we/dust/code/palouse/dawns/"..util.round(dawn)

local history_by_index = {}
local history_by_timestamp = {}
local fns = {}
local sc_fns = {}
local ndefs = {}

-- TODO:
-- [ ] immediate history recall (i.e. "bring me up to speed")
-- [ ] fluent API: .draw("s").freq(400)
-- [ ] better logging
-- [ ] low/high -> mul/add
-- [ ] list of available "primes" (I dislike this name)
-- [x] autosave history to JSON

print("hello my name is good name and that is a GOOD NAME")

function get_ts()
  return util.time() - dawn
end

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
      g.record_event(name, args)
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
      g.record_event(fn, cmd_name, args)
    end
  end
end

-- TODO: do literally anything, RECORD IT

-- lol please do not expose this and double-record
function g.record_event(name, args, ts) 
  if ts == nil then
    ts = get_ts()
  end
  args.n = nil
  local event = {name=name,args=args,ts=ts}
  history_by_index[#history_by_index+1] = event
  history_by_timestamp[ts] = event

  print(history_by_index, dawn_file)
  json.save(history_by_index, ""..dawn_file)
  print("recorded ("..name..") w/ "..#args.." args at "..
  string.format("%.4f",ts).." seconds")
end

function apply(fn, ...) 
  fn(...)
end

-- by timestamp is probably better
-- but I'm getting tired lol
function g.play_by_index(index)
  local event = history_by_index[index]
  print("playing ("..event.name..") w/ "..#event.args..
    " args at "..event.ts.." seconds")
  apply(fns[event.name], table.unpack(event.args))
end

function g.list_events (index)
  for i=1,#history_by_index do
    local e = history_by_index[i]
    print(string.format("%.4f",e.ts)..": "..e.name.."("..join(e.args)..")")
  end
end

local wave = function()
  print("waved.")
end

-- a "shell" is like a placeholder Ndef
-- like what we did in FCV
function create_shell(name)
  engine.create_shell(name)
end

-- play and move_to_head suck. confusing.
-- .play is easy.
-- for move_to_head, 
-- try .duck() and .jump() instead
-- w/ no arg = moveToHead. w/ arg = moveBefore, etc.
local draw = function (fn_name, ndef_name, ...)
  if sc_fns[fn_name] == nil then
    sc_fns[fn_name] = {}
  end

  local index = #sc_fns[fn_name] + 1

  if ndef_name == nil then
    ndef_name = fn_name..index
  end

  engine.make(fn_name, ndef_name)

  -- TODO add self/function for fluent/literate API
  local specimen = { ndef_name=ndef_name, fn_name=fn_name, ins={}, outs={} }
  -- same thing by reference (I hope...)
  ndefs[ndef_name] = specimen
  sc_fns[fn_name][index] = specimen
  print("drew a(n) '"..fn_name.."' (#"..index..") named '"..ndef_name.."'.")
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

--expose(list_events, "list_events")
expose(play_by_index, "play_event")
expose(wave, "wave")
expose(redraw, "redraw")
expose(draw, "draw")
expose(plug, "plug")
--expose_engine("create_prime") -- hail? draw?
expose_engine("set")
expose_engine("free")
expose_engine("play")
--expose_engine("plug")

return g
