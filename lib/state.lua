local history = include("lib/history")

local s = {
  models = {},
  nacelles = {},
  pylons = {},
}

function s.record_engine(cmd_name, ...)
  history.record_event(cmd_name, table.pack(...))
end

function s.add_model(model_name)
  s.models[model_name] = { nacelles={} }
end

function s.model_nacelle_count(model_name)
  return #s.models[model_name].nacelles
end

function s.model_newindex(model_name)
  return #s.models[model_name].nacelles + 1
end

function s.set_nacelle_param(nacelle_name, param_name, value)
  s.nacelles[nacelle_name].params[param_name] = value
  state.record_engine('set', nacelle_name, param_name, value)
end

-- ha, could use metamethods for the state here.
function s.plug_nacelle(to_nacelle, param_name, from_nacelle)
  s.nacelles[to_nacelle].ins[param_name] = from_nacelle 

  if not s.nacelles[from_nacelle].outs[from_nacelle] then
    s.nacelles[from_nacelle].outs[to_nacelle] = {}
  end

  table.insert(s.nacelles[from_nacelle].outs[to_nacelle], param_name)

  state.record_engine('plug', to_nacelle, param_name, from_nacelle)
end

function s.new_nacelle(model_name, nacelle_name)
  local nacelle = { 
    nacelle_name=nacelle_name, 
    model_name=model_name, 
    params={}, 
    ins={}, 
    outs={} 
  }
  -- same thing by reference (I hope...)
  s.nacelles[nacelle_name] = nacelle
  s.models[model_name].nacelles[s.model_newindex(model_name)] = nacelle
  print("(re)drew a(n) '"..model_name.."' (#"..s.model_nacelle_count(model_name)..
    ") named '"..nacelle_name.."'.")
  state.record_engine('make', model_name, nacelle_name)
end

return s
