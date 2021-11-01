local r = {}

local explicit_globals = include("lib/globals")

function r.set_params(nacelle_name, params)
  if type(params) ~= 'table' or #params > 0 then
    print("params must be an associative table")
    return
  end

  for key, value in pairs(params) do
    print('set_params:', nacelle_name, key, value)
    engine.set(nacelle_name, key, value)
    state.set_nacelle_param(nacelle_name, key, value)
  end
end

function r.nacelle_context (nacelle_name, fn)
  local context = { nacelle_name=nacelle_name, fn=fn }
  print('new nacelle context for '..nacelle_name)

  local play = function ()
    engine.play(nacelle_name)
    state.record_engine('play', nacelle_name)
  end

  --print('welcome to the context of nacelle '..nacelle_name)

  setmetatable(context, {
    __index = function (t, key) 
      --if key == 'draw' then
      --  return draw
      --end

      if key == 'play' then
        rawset(context, 'fn', 'play')
        play() -- don't need params yet - save some typing
        return context
      end

      if key == 'set' then
        rawset(context, 'fn', 'set')
        return context
      end

      print(nacelle_name.."'s "..key)
      local x 

      x = state.nacelles[nacelle_name].params[key]
      if x ~= nil then return x end

      x = explicit_globals[key]
      if x then return x end

      -- took me a minute to find this
      -- https://sodocumentation.net/lua/topic/2444/metatables#raw-table-access
      x = rawget(t,key)

      if x then return x end
      print("failed to get value for model key: "..key)
    end,
    __newindex = function (t, key, value)
      print('this is newindex')
      r.set_params(nacelle_name, {[key]=value})
    end,
    __call = function (t, ...)
      local fn = rawget(context, 'fn')
      local args = table.pack(...)
      print('called '..fn..' with '..#args..' args:')
      for i=1,#args do
        print('arg #'..i..':')
        if type(args[i]) == 'table' then 
          tu.print(args[i])
        else
          print(args[i])
        end
      end
      if fn == 'play' then
        play()
        state.record_engine('play', nacelle_name)
      end

      if fn == nil then
        local nacelle = state.nacelles[nacelle_name]

        engine.make(nacelle.model_name, nacelle.nacelle_name)
        state.new_nacelle(nacelle.model_name, nacelle.nacelle_name)

        play()
      end

      if (fn == 'set' or fn == nil) and type(args[1]) == 'table' then
        r.set_params(nacelle_name, args[1])
        rawset(context, 'fn', nil)
      end

      return context
    end
  })
  return context
end

local model_context = function(model_name)
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
  local draw = function (t, ...)
    local nacelle_name = nil
    local args = table.pack(...)

    -- sin()
    if #args == 0 then 
      -- nothing, right?
      -- just make the thing & give it defaults
      
    -- sin('mysin')
    elseif type(args[1]) == 'string' then 
      nacelle_name = args[1]
      if nacelle_name == model_name then
        print('cannot name nacelle same thing as model')
        return
      end
      -- (see below for table case)

      -- what's left? numbers? 
      -- (numbers won't work/make-sense w/o param introspection)
    else
    end

    if nacelle_name == nil then
      nacelle_name = model_name..state.model_newindex(model_name)
    end

    engine.make(model_name, nacelle_name)
    state.new_nacelle(model_name, nacelle_name)

    if type(args[1]) == 'table' then
      print('(draw) watch closely...')
      for i=1,#args do
        print('arg #'..i..':')
        if type(args[i]) == 'table' then 
          tu.print(args[i])
        else
          print(args[i])
        end
      end
      print('..did you see it?')
      -- I think we can do this as a table
      -- but then jt's varargs, which the LUA->engine API doesn't like
      r.set_params(nacelle_name, args[1])
    end

    return r.nacelle_context(nacelle_name) -- this context is new
  end

  local context = { model_name=model_name }
  --print('creating model context for '..model_name..'.')

  setmetatable(context, {
    __index = function (t, key) 
      --if key == 'draw' then
      --  return draw
      --end

      print(name.."'s "..key)
      local x 
      x = explicit_globals[key]
      if x then return x end

      -- took me a minute to find this
      -- https://sodocumentation.net/lua/topic/2444/metatables#raw-table-access
      x = rawget(t,key)

      if x then return x end
      print("failed to get value for model key: "..key)
    end,
    __call = draw
  })
  return context
end

-- I think we should call these models.
function r.list_models ()
  print('all models:')
  for k, v in pairs(state.models) do
    -- v doesn't have anything yet...
    print(k)
  end
end

-- nacelles are more like individual ndefs.
function r.list_nacelles ()
  print('all nacelles:')
  for k, v in pairs(state.nacelles) do
    -- v doesn't have anything yet...
    print(k)
  end
end

-- and maybe the pylon is the connections...?

function r.init()
  setmetatable(_G, {
    __index = function (t, key) 
      if key == 'models' then 
        r.list_models()
        return
      end

      if key == 'nacelles' then 
        r.list_nacelles()
        return
      end

      local x 
      x = explicit_globals[key]
      if x then return x end

      x = state.models[key]
      if x then
        return model_context(key)
      end

      x = state.nacelles[key]
      if x then
        return r.nacelle_context(key)
      end

      x = rawget(t,key)
      if x then return x end
      print("failed to get value for global key: "..key)
    end
  })
end

return r
