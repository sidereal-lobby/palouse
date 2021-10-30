-- from @schollz's o-o-o 
cj = require('cjson')

local j = {}

function j.encode(data)
  local str=cj.encode(data)
  return str
end

function j.decode(str)
  local data=cj.decode(str)
  return data
end

function j.load(filename)
  filename=filename..".json"
  print("o-o-o: loading "..filename)
  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()

  local data=cj.decode(content)
  return data
end

function j.save(data, filename)
  print(type(data))
  print(data)
  local str = cj.encode(data)

  filename=filename..".json"
  print("o-o-o: saving "..filename)
  local file=io.open(filename,"w+")
  io.output(file)
  io.write(str)
  io.close(file)
end

return j
