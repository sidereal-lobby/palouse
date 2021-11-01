local h = {}

h.dawn = util.time()
local dawn_file = "/home/we/dust/code/palouse/dawns/"..util.round(h.dawn)
local by_index = {}
local by_timestamp = {}

local apply = function (fn, ...) 
  fn(...)
end

function h.get_ts()
  return util.time() - h.dawn
end

-- lol please do not expose this and double-record
function h.record_event(name, args, ts) 
  if ts == nil then
    ts = h.get_ts()
  end
  args.n = nil
  local event = {name=name,args=args,ts=ts}
  by_index[#by_index+1] = event
  by_timestamp[ts] = event

  --print(by_index, dawn_file)
  json.save(by_index, ""..dawn_file)
  print("recorded ("..name..") w/ "..#args.." args at "..
  string.format("%.4f",ts).." seconds")
end

function h.list_events (index)
  for i=1,#by_index do
    local e = by_index[i]
    print(string.format("%.4f",e.ts)..": "..e.name.."("..join(e.args)..")")
  end
end

-- by timestamp is probably better
-- but I'm getting tired lol
function h.play_by_index(index)
  local event = by_index[index]
  print("playing ("..event.name..") w/ "..#event.args..
    " args at "..event.ts.." seconds")
  apply(h.fns[event.name], table.unpack(event.args))
end

return h
