local fn = {}

function fn.init()
  fn.id_counter = 1000
end

function fn.load_config()
  -- https://stackoverflow.com/a/41176826
  local file = "/home/we/dust/code/palouse/lib/config.lua"
  config = {} -- global
  local apply, err = loadfile(file, "t", config)
  if apply then
    apply()
    --print("loading your config...")
    tu.print(config)
  else
    print(err)
    local apply, err = loadfile("/home/we/dust/code/palouse/lib/default-config.lua", "t", config)
    if apply then
      apply()
      --print("loading default config instead...")
      tu.print(config)
    end
  end
  --print("")
end

function fn.light_bonfire()
  bonfire = io.open("/home/we/dust/code/palouse/lib/bonfire.lua", "r")
  if bonfire ~= nil then
    io.close(bonfire)
    print("lighting your bonfire...")
    include("palouse/lib/" .. "bonfire")
  else
    print("lighting default bonfire...")
    include("palouse/lib/" .. "default-bonfire")
  end
end

function fn.id(prefix)
  -- a servicable attempt creating unique ids
  fn.id_counter = fn.id_counter + 1
  return prefix .. "-" .. os.time(os.date("!*t")) .. "-" .. fn.id_counter
end

function fn.print(s)
  print("")
    print("")  
      print("")
        print(s) -- SWOOSH
      print("")
    print("")
  print("")
end

function fn.screen_dirty(bool)
  if bool == nil then return screen_dirty end
  --screen_dirty = bool
  screen_dirty = true
  return screen_dirty
end

function fn.get_name()
  return metadata.name
end

function fn.get_version()
  return metadata.version_major .. "." ..
         metadata.version_minor .. "." ..
         metadata.version_patch
end

function fn.rerun()
  norns.script.load(norns.state.script)
end

return fn
