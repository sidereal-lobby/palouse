local g = {}

local history_by_index = {}
local history_by_timestamp = {}

print("hello my name is good name and that is a GOOD NAME")

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
      g.record_event(fn, name, ts, args)
    end
  end
end

function expose_engine(name)
  local cmd = engine.commands[name]
  if not cmd then 
    print("engine has no command '"..name.."'")
    return
  else
    print("expose engine command '"..name..
      "' ("..#cmd.fmt.." args: "..cmd.fmt..")")
    g[name] = function (...)
      cmd.func(...)
      local args = table.pack(...)
      g.record_event(fn, name, ts, args)
    end
  end
end

-- TODO: do literally anything, RECORD IT

-- lol please do not expose this and double-record
function g.record_event(fn, name, ts, args) 
  local ts = util.time() - dawn -- a little later, whatever
  local event = {name=name,fn=fn,args=args,ts=ts}
  history_by_index[#history_by_index+1] = event
  history_by_timestamp[ts] = event
  -- TODO: record this somewhere non-volatile
  print("recorded ("..name..") w/ "..#args.." args at "..ts.." seconds")
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

-- real easy to imagine this getting tedious.
-- maybe an "API function wrapper" is in order.
function jack_shit()
  print("doing jack shit")
end

-- a "shell" is like a placeholder Ndef
-- like what we did in FCV
function create_shell(name)
  engine.create_shell(name)
end

expose(play_by_index, "play_event")
expose(jack_shit, "jack_shit")
expose_engine("create_prime")
expose_engine("set_param")
expose_engine("plug")

return g
