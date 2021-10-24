local network = {}

-- cpath tweak for binary import
local orig_cpath = package.cpath
-- cpath must be set BEFORE including
if not string.find(orig_cpath,"/home/we/dust/code/fcv/lib/") then
  package.cpath=orig_cpath..";/home/we/dust/code/fcv/lib/?.so"
end
local client = include("lib/websocket")


function network.init()
  network.ready = false
  print('connecting to ', config.ws_relay_host, config.ws_relay_port)
  client = client.new(config.ws_relay_host, config.ws_relay_port)

  function client:onmessage(s) 
    local break_index = string.find(s, '\n')
    if break_index ~= nil and break_index > 1 then
      -- get the command
      local command = string.sub(s, 1, break_index - 1) 
      local content = string.sub(s, break_index + 1, #s) 

      -- process the command
      if command == 'MSG' then
        print('HEY YOU. I GOT A MESSAGE FOR YA:\n"'..content..'"') 
      elseif command == 'LUA' then
        print('executing as lua:\n'..content)
        local success, result = pcall(load(content))
        if success then
          print("<OK>")
          print(result)
        else
          print("oh FUCK ERROR!!!!")
          print(result)
        end
      elseif command == 'SC' then
        local result = engine.eval(content);
        print('result of SC: '..(result ~= nil and result or '(nil)'))
      else
        print('unknown command "'..command..'"')
      end
    end
  end

  function client:onopen() 
    self:send('MSG\noh hi, my name is '..(config.norns_name or 'AN UNKNOWN NORNS')) 
    network.ready = true
  end

  function client:onclose(s) 
    print("shut it down") 
    network.ready = false
    client = client.new(config.ws_relay_host, config.ws_relay_port)
  end
  print('bye')
end

function network.init_clock()
  network_lattice = lattice:new{}
  network_pattern = network_lattice:new_pattern{
    action = network.step
  }
  network_lattice:start()
end

function network.step()
  client:update()
  if not network.ready then 
    -- print("please wait to connect...")
    return
  end
end

function network.tx_lua(code)
  if network.ready then
    client:send('LUA\n'..code)
  else
    print("can't send code - network not ready")
  end
end

called_step = false

function network:cleanup()
  print('cleaning up network...')
  -- assumes this module contains the only cpath tweak
  package.cpath = orig_cpath 
  if client and type(client.close) == 'function' then client:close() end
end

return network
