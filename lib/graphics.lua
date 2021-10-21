
local graphics = {}

function graphics.init()
  graphics.fps = 15
  graphics.buffer = "SiLo"
end


function graphics:draw_splash()
  self:setup()
  self:circle(8, 8, 8, 15)
  self:circle(120, 8, 8, 15)
  self:circle(120, 56, 8, 15)
  self:circle(8, 56, 8, 15)
  self:rect(0, 5, 128, 55, 15)
  self:rect(5, 0, 118, 64, 15)
  self:rect(44, 22, 1, 1, 0)
  self:rect(84, 42, 1, 1, 0)
  screen.font_face(64)
  self:text_center(64, 36, "SiLo", 0)
  self:teardown()  
end

function graphics:peek()
  -- (128 / 2) - 20 = 44 
  -- (128 / 2) + 20 = 84
  -- (64 / 2) -  10 = 22
  -- (64 / 2) + 10 = 42
  self.buffer = screen.peek(44, 22, 40, 20)
print(self.buffer)
  self:teardown()  

end

function graphics:poke()
  -- self:setup()
  screen.poke(0, 0, 128, 64, self.buffer)
  self:teardown()  
end

function graphics:draw_home()
  self:setup()
  self:text_center(64, 40, fn:get_name(), 15)
  self:text_center(64, 50, fn:get_version(), 15)
  self:teardown()
end

function graphics:setup()
  screen.clear()
  screen.aa(0)
  self:reset_font()
end

function graphics:reset_font()
  screen.font_face(0)
  screen.font_size(8)
end

function graphics:teardown()
  screen.update()
end


-- northern information
-- graphics library

function graphics.init()
  screen.aa(0)
  screen.font_face(0)
  screen.font_size(8)
end



function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_right(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_right(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end

return graphics