local r = {}

local log

-- these probably don't need to be public
-- but I don't completely understand how metatables mess with scope
function r.list_models()
  local str = 'all models:'
  for k, v in pairs(state.models) do
    str = str..'\t'..k
  end
  return str..'\r'
end

function r.list_nacelles()
  local str = 'all nacelles:'
  for k, v in pairs(state.nacelles) do
    str = str..'\t'..k
  end
  return str..'\r'
end

function r.draw(model_context, ...)
  log.debug("CALLING DRAW")
  local nacelle_name = nil
  local args = table.pack(...)

  -- sin()
  if #args == 0 then 
    -- nothing, right?
    -- just make the thing & give it defaults
    
  -- sin('mysin')
  elseif type(args[1]) == 'string' then 
    nacelle_name = args[1]
    if nacelle_name == model_context.model_name then
      log.error('cannot name nacelle same thing as model')
      return
    end
    -- (see below for table case)

  -- what's left? numbers? 
  -- (numbers won't work/make-sense w/o param introspection)
  else
  end

  if nacelle_name == nil then
    nacelle_name = model_context.model_name..
      state.model_newindex(model_context.model_name)
  end

  engine.make(model_context.model_name, nacelle_name)
  state.new_nacelle(model_context.model_name, nacelle_name)

  local new_nacelle_context = r.nacelle_context(nacelle_name)

  if type(args[1]) == 'table' then
    return r.set_params(new_nacelle_context, args[1])
  end

  return new_nacelle_context
end

function r.play(nacelle_context)
  log.debug("PLAYING NACELLE")
  log.debug(nacelle_context)
  engine.play(nacelle_context.nacelle_name)
  state.record_engine('play', nacelle_context.nacelle_name)

  return nacelle_context
end

-- this shouldn't return a context
-- because it's used by both (nacelle) set_params
-- and (nacelle param) set
function r.set_param(nacelle_name, param_name, value)
  engine.set(nacelle_name, param_name, value)
  state.set_nacelle_param(nacelle_name, param_name, value)
end

-- should this take the name or the table?
function r.set_params(nacelle_context, params)
  if type(params) ~= 'table' or #params > 0 then
    log.error("params must be an associative table")
    return
  end

  for key, value in pairs(params) do
    log.debug("PARAM "..key.." = "..value)
    r.set_param(nacelle_context.nacelle_name, key, value)
  end

  return nacelle_context
end

function r.plug(receiver, input, sender)
  if state.nacelles[receiver] == nil then
    log.error("receiver "..receiver.." not found...") 
    return
  elseif state.nacelles[sender] == nil then
    log.error("sender "..sender.." not found...") 
    return
  end

  log.debug("PLUGGING "..sender.." INTO "..receiver.."'s "..input)
  engine.plug(receiver, input, sender)

  -- state.nacelles[sender].outs = { rx=receiver, i=input }
  --state.nacelles[receiver].ins[input] = sender
  --state.record_engine('plug', receiver, input, sender)
  state.plug_nacelle(receiver, input, receiver)
end

--function r.send(t, input, receiver)
--end

local model_meta = {
  __index = function (model_context, key) 
    if key == 'play' then
      log.debug("PLAYING FROM MODEL CONTEXT")
      return r.draw(model_context).play
    end

    -- https://sodocumentation.net/lua/topic/2444/metatables#raw-table-access
    local x = rawget(model_context, key)
    if x then return x end

    log.error("failed to get value for model key: "..key)
  end,
  __call = r.draw
}

local nacelle_meta = {
  __index = function (nacelle_context, key) 
    if key == 'play' then
      --rawset(nacelle_context, 'fn', 'play')
      log.debug("PLAYING FROM NACELLE")
      r.play(nacelle_context) -- don't need params - save some typing
      return nacelle_context
    end

    if key == 'set' then
      rawset(nacelle_context, 'fn', 'set')
      return nacelle_context
    end

    local x 

    -- this should be sensitive to default params
    -- but it won't work until it is
    -- x = state.nacelles[nacelle_context.nacelle_name].params[key] -- CORRECT
    x = state.nacelles[nacelle_context.nacelle_name].params -- TEMP HAX
    if x then
      return r.nacelle_param_context(nacelle_context.nacelle_name, key)
    end

    -- https://sodocumentation.net/lua/topic/2444/metatables#raw-table-access
    x = rawget(nacelle_context,key)
    if x then return x end

    log.error("failed to get value for nacelle key: "..key)
  end,
  __newindex = function (nacelle_context, key, value)
    r.set_params(nacelle_context, {[key]=value})
  end,
  __call = function (nacelle_context, ...)
    local fn = rawget(nacelle_context, 'fn')
    local args = table.pack(...)

    if fn == 'play' then
      r.play(nacelle_context)
      state.record_engine('play', nacelle_context.nacelle_name)
    end

    if fn == nil then
      local nacelle = state.nacelles[nacelle_context.nacelle_name]

      engine.make(nacelle.model_name, nacelle.nacelle_name)
      state.new_nacelle(nacelle.model_name, nacelle.nacelle_name)

      r.play(nacelle_context)
    end

    if (fn == 'set' or fn == nil) and type(args[1]) == 'table' then
      log.debug("SETTING PARAMS. fn = "..(fn or "(nil)").."args[1] = ")
      log.debug(args[1])
      r.set_params(nacelle_context, args[1])
      rawset(nacelle_context, 'fn', nil)
    end

    return nacelle_context
  end
}

local nacelle_param_meta = {
  -- we care about 1 param, tops
  __index = function (param_context, key)
    if key == 'play' then
      local nacelle_context = r.nacelle_context(param_context.nacelle_name)
      nacelle_context.play(nacelle_context)
    end

    if key == 'lag' then
    end
  end,
  __call = function (param_context, value)
    -- it's a getter
    if value == nil then
      -- this does NOT WORK if it's plugged!
      return state.nacelles[param_context.nacelle_name].
        params[param_context.param_name]
    end

    -- it's a getter
    if type(value) == "number" then
      r.set_param(param_context.nacelle_name, param_context.param_name, value)
      return param_context
    end

    if r.is_nacelle(value) then
      r.plug(param_context.nacelle_name, param_context.param_name, 
        value.nacelle_name)
      return param_context
    end

    log.error(param_context.nacelle_name.."."..param_context.param_name..
      " does not know what to do with this value")
  end
}

function r.is_model(t)
  return getmetatable(t) == model_meta
end

function r.is_nacelle(t)
  return getmetatable(t) == nacelle_meta
end

function r.is_nacelle_param(t)
  return getmetatable(t) == nacelle_param_meta
end

function r.nacelle_param_context(nacelle_name, param_name)
  log.debug('CREATING NACELLE PARAM CONTEXT FOR '..nacelle_name..'.'..param_name)
  local context = { nacelle_name=nacelle_name, param_name=param_name }

  setmetatable(context, nacelle_param_meta)
  return context
end

function r.nacelle_context(nacelle_name, fn)
  log.debug('CREATING NACELLE CONTEXT FOR '..nacelle_name)
  local context = { nacelle_name=nacelle_name, fn=fn }

  -- for plug, we'll want both nacelle contexts
  -- the metatable "validates" that a nacelle exists
  -- just by virtue of the lookup
  -- so really the missing component is: is_nacelle()
  -- I believe sequins implemented the same thing

  setmetatable(context, nacelle_meta)
  return context
end

function r.model_context(model_name)
  log.debug('CREATING MODEL CONTEXT FOR '..model_name)
  -- play and move_to_head suck. confusing.
  -- .play is easy.
  -- for move_to_head, 
  -- try .duck() and .jump() instead
  -- w/ no arg = moveToHead. w/ arg = moveBefore, etc.

  -- sooooo there's a few parts to this that need unpacking:
  -- - parameter collating
  -- - actually calling the engine with well-formed parameters
  -- - book-keeping
  -- - timestamping (is this a subset of book-keeping?

  local context = { model_name=model_name }
  setmetatable(context, model_meta)
  log.debug('RETURNING CONTEXT FOR '..model_name)
  return context
end


-- model -> nacelle -> maybe pylon is connections...?

-- GLOBAL REPL
function r.init()
  print('making REPL logger')
  log = logger.make("repl")
  print('made REPL logger')

  -- procrastinate on this, so all globals accounted for
  local explicit_globals = include("lib/globals")
  setmetatable(_G, {
    __index = function (t, key) 
      if key == 'models' then 
        return r.list_models() -- returning string is less noisy
      end

      if key == 'nacelles' then 
        return r.list_nacelles() -- returning string is less noisy
      end

      if key == 'repl' then 
        return r
      end

      local x 

      x = explicit_globals[key]
      if x then return x end

      x = state.models[key]
      if x then
        log.debug("MODEL CONTEXT OF "..key)
        return r.model_context(key)
      end

      x = state.nacelles[key]
      if x then
        return r.nacelle_context(key)
      end

      x = rawget(t,key)
      if x then return x end
      log.error("failed to get value for global key: "..key)
    end
  })
end

return r
