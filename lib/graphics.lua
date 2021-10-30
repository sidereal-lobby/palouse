
local graphics = {}

local card = "   x " ..
             "  x x" ..
             " x  x" ..
             "x   x" ..
             "x   x" ..
             "x   x" ..
             "x   x" ..
             "x   x" ..
             "x   x" ..
             "x  x " ..
             "x x  " ..
             " x   " 

local card_sprite = {"","","","","",""}

local card_y = {0,1,2,4,7,11}

function graphics.init()
  graphics.fps = 15
  graphics.splash_bg = 15
  graphics.view = 1
  local temp_card = ""
  for i=1,#card do
    local on = string.sub(card, i, i) ~= ' '
    for i=1,6 do
      card_sprite[i] = card_sprite[i] .. string.char(on and i or 0)
    end
  end
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
end

function graphics:is_home()
  return true -- just a stub for now
end

-- private for draw_cards()
function card_sprite_color(idx)
  local frame = clocks.redraw_frame % 86
  frame = frame - 30

  local distance = math.abs(idx - frame)
  if distance > 4 then return 1 end
  return 6 - distance
end

-- private for draw_home()
function draw_cards(x, y)
  for idx=1,16 do
    local color = card_sprite_color(idx)
    --local color = clocks.redraw_frame % 6 + 1
    screen.poke(idx*4-x, y - card_y[color], 5, 12, card_sprite[color])
  end
end

-- private for various draws_*
function get_network_status()
  return network.ready and ":) :)" or ":("
end

function draw_bpm()
  screen.font_face(8)
  screen.font_size(32)
  screen.aa(1)
  graphics:text(0, 28, tempo_cache, 15)
  graphics:reset_font()
end

function graphics:draw_home()
  draw_bpm()
  draw_cards(5, 52)
  self:text_right(128, 56, get_network_status(), 5)
  self:text_right(128, 64, fn.get_hash() .. " v" .. fn.get_version(), 1)
end

function graphics:setup()
  screen.clear()
  self:reset_font()
end

function graphics:reset_font()
  screen.aa(0)
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
