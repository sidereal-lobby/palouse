local fn = {}

function fn.init()
  fn.id_counter = 1000
  fn.git_hash = "gitgot"
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
  local file = "/home/we/dust/code/palouse/lib/config.lua"
  config = {} -- global
  local apply, err = loadfile(file, "t", config)
  if apply then
    apply()
    print("loading your config...")
    tu.print(config)
  else
    print(err)
    local apply, err = loadfile("/home/we/dust/code/palouse/lib/default-config.lua", "t", config)
    if apply then
      apply()
      print("loading default config instead...")
      tu.print(config)
    end
  end
  print("")
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
        print(s)
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

function fn.get_hash()
  if clock.redraw_frame % 120 = 0 then
    self.git_hash = fn.os_capture("cd /home/we/dust/code/palouse && git rev-parse HEAD")
  end
  return string.sub(self.git_hash, 1, 6)
end

return fn
