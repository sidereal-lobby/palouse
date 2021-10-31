local fn = {}

function fn.init()
  fn.id_counter = 1000
  fn.git_hash = "gitgot"
  fn.cache_git()
  fn.print("P A L O U S E")
end

function fn.os_capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

function fn.load_config()
  -- https://stackoverflow.com/a/41176826
  local file = metadata.absolute_path .. "/lib/config.lua"
  config = {} -- global
  local apply, err = loadfile(file, "t", config)
  if apply then
    apply()
    --print("loading your config...")
    tu.print(config)
  else
    print(err)
    local apply, err = loadfile(metadata.absolute_path.."/lib/default-config.lua", "t", config)
    if apply then
      apply()
      --print("loading default config instead...")
      tu.print(config)
    end
  end
  --print("")
end

function fn.light_bonfire()
  bonfire = io.open(metadata.absolute_path.."/lib/bonfire.lua", "r")
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

function fn.get_name()
  return metadata.name
end

function fn.get_version()
  return metadata.version_major .. "." ..
         metadata.version_minor .. "." ..
         metadata.version_patch
end

function fn.cache_git()
  fn.git_hash = fn.os_capture("cd " .. metadata.absolute_path .. " && git rev-parse HEAD")
end

function fn.get_hash()
  if clocks.redraw_frame % 120 == 0 then
    fn.cache_git()
  end
  return string.sub(fn.git_hash, 1, 6)
end

return fn
