local l = {}
-- construct a logger based on the component
-- check config for component debug status
local level_enum = {
  debug = 1,
  info  = 2,
  warn  = 3,
  error = 4,
}

local noop = function () end
local do_log = function (head, ...) 
  -- this could be problematic, but it seems handy
  if type(head) == 'table' then
    tu.print(head)
  else
    print(head, ...) 
  end
end

-- debug, info, warn, error
function l.make(speaking_component)
  local component_log = {}
  local reload = function ()
    -- set threshold here so it can be reloaded on-the-fly
    local threshold = level_enum[config.log_levels[speaking_component]]

    for str_level, int_level in pairs(level_enum) do
      -- lower threshold = more logs
      local show = (threshold <= int_level)
      component_log[str_level] = show and do_log or noop
    end
  end
  component_log.reload = reload

  reload()

  return component_log
end

return l
