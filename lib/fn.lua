local fn = {}

function fn.init()
  fn.id_counter = 1000
  fn.git_hash = "gitgot"
  fn.cache_git()
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

function fn.set_default_params()
  -- compressor settings
  params:set("compressor",      2)    -- off 1, on 2
  params:set("comp_mix",        0.5)  -- 0.0 - 1.0
  params:set("comp_ratio",      4.0)  -- 1.0 - 20.0
  params:set("comp_threshold",  -9.0) -- dB
  params:set("comp_attack",     5.0)  -- ms
  params:set("comp_release",    51.0) -- ms
  params:set("comp_pre_gain",   0.0)  -- dB
  params:set("comp_post_gain",  9.0)  -- dB

  -- reverb settings
  params:set("reverb",            p.reverb())
  params:set("rev_eng_input",     -9.0)   -- dB
  params:set("rev_cut_input",     -9.0)   -- dB
  params:set("rev_monitor_input", -100.0) -- dB
  params:set("rev_tape_input",    -100.0) -- dB
  params:set("rev_return_level",  p.rev_return_level())
  params:set("rev_pre_delay",     p.rev_pre_delay())
  params:set("rev_lf_fc",         p.rev_lf_fc())
  params:set("rev_low_time",      p.rev_low_time())
  params:set("rev_mid_time",      p.rev_mid_time())
  params:set("rev_hf_damping",    p.rev_hf_damping())
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

function fn.cache_git()
  fn.git_hash = fn.os_capture("cd /home/we/dust/code/palouse && git rev-parse HEAD")
end

function fn.get_hash()
  if clocks.redraw_frame % 120 == 0 then
    fn.cache_git()
  end
  return string.sub(fn.git_hash, 1, 6)
end

return fn
