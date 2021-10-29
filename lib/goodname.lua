local g = {}

local history_by_index = {}
local history_by_timestamp = {}
local ndefs = {}
local specimens = {}

-- two things I want RIGHT NOW:
-- - immediate history recall (i.e. "bring me up to speed")
-- - fluent API: .draw("s").freq(400)
-- - better fucking logging

print("hello my name is good name and that is a GOOD NAME")

function get_ts()
  return util.time() - dawn
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
    g[name] = function (...)
      fn(...)
      local args = table.pack(...)
      g.record_event(fn, name, args)
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
function g.record_event(fn, name, args, ts) 
  if ts == nil then
    ts = get_ts()
  end
  local event = {name=name,fn=fn,args=args,ts=ts}
  history_by_index[#history_by_index+1] = event
  history_by_timestamp[ts] = event
  -- TODO: record this somewhere non-volatile
  print("recorded ("..name..") w/ "..#args.." args at "..
  string.format("%.4f",ts).." seconds")
end

function apply(fn, ...) 
  fn(...)
end

-- by timestamp is probably better
-- but I'm getting tired lol
function play_by_index(index)
  local event = history_by_index[index]
  print("playing ("..event.name..") w/ "..#event.args..
    " args at "..event.ts.." seconds")
  apply(event.fn, table.unpack(event.args))
end

function g.list_events (index)
  for i=1,#history_by_index do
    local e = history_by_index[i]
    local msg = "at "..string.format("%.4f",e.ts)..", "..e.name
    if #e.args > 0 then
      print(msg.." with args:")
      tu.print(e.args)
    else
      print(msg..".")
    end
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

local draw = function (ndef, name, play, move_to_head)
  if ndefs[ndef] == nil then
    ndefs[ndef] = {}
  end

  local index = #ndefs[ndef] + 1

  if name == nil then
    name = ndef..index
  end

  engine.create_prime(ndef, name, play, move_to_head)

  -- TODO add self/function for fluent/literate API
  local specimen = { name=name, ndef=ndef, ins={}, outs={} }
  -- same thing by reference (I hope...)
  specimens[name] = specimen
  ndefs[ndef][index] = specimen
  print("drew a(n) '"..ndef.."' (#"..index..") named '"..name.."'.")
end

local plug = function (receiver, input, sender)
  if specimens[receiver] == nil then
    print("receiver "..receiver.." not found...") 
    return
  elseif specimens[sender] == nil then
    print("sender "..sender.." not found...") 
    return
  end

  engine.plug(receiver, input, sender)

  specimens[sender].outs = { rx=receiver, i=input }
  specimens[receiver].ins[input] = sender

  print("plugged "..sender.." into "..receiver.."'s "..input..".")
end

--expose(list_events, "list_events")
expose(play_by_index, "play_event")
expose(wave, "wave")
expose(draw, "draw")
expose(plug, "plug")
--expose_engine("create_prime") -- hail? draw?
expose_engine("set_param")
--expose_engine("plug")

return g
