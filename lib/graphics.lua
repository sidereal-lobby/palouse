
local graphics = {}

function graphics.init()
  graphics.fps = 15
  graphics.splash_bg = 15
end

function graphics:render()
  self:setup()
  if self:is_splash() then
    self:draw_splash()
  elseif self:is_home() then
    self:draw_home()
  else
    self:draw_home()
  end
  self:teardown()  
end

function graphics:is_splash()
  return clocks.redraw_frame < 15
end

function graphics:draw_splash()
  self.splash_bg = self.splash_bg - 1
  self:rect(0, 0, 128, 64, self.splash_bg)
  screen.font_face(33)
  screen.font_size(16)
  self:text_center(64, 36, "P A L O U S E", (-1 * (self.splash_bg - 15)))
  if self.splash_bg < 0 then
    self.splash_bg = 15
  end
  fn.screen_dirty(true)
end

function graphics:is_home()
  return true -- just a stub for now
end

function graphics:draw_home()
  self:text_right(128, 56, fn:get_name(), 15)
  self:text_right(128, 64, fn:get_version(), 15)
end

function graphics:setup()
  screen.clear()
  screen.aa(1)
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