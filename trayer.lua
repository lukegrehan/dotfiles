local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

function toggle(self)
  self.wibox.visible  = not self.wibox.visible
  if self.wibox.visible then
    self:update()
  end
end

-- Module tray
local tray = {}

function getwidth(self)
  local function getW(widget)
    local w,_ = widget:fit(1000000, 0)
    return w
  end

  --for _,v in ipairs(self.widgets) do
--    print(getW(v))
--  end

  return 200
end

function getheight(self)
  local function getH(widget)
    local _,h = widget:fit(1000000, 0)
    return h
  end

--  for k,v in ipairs(self.widgets) do
 --   print(k)
--    print(v)
 -- end

  return 20
end

function add(self, widget)
  table.insert(self.widgets, widget)
  self.layout:add(widget)
  self:update()
end

function update(self)
  self.geom.width = self:getwidth()
  self.geom.height = self:getheight()

  self.wibox:geometry(self.geom)
end

function tray.new(s, geometry)
  local scrgeom = screen[s].workarea
  local geom = {
    x = geometry.x or (scrgeom.width - scrgeom.x),
    y = geometry.y or scrgeom.y
  }

  if(geometry.ontop ~= nil) then
    geom.ontop = geometry.ontop
  else
    geom.ontop = true
  end

  if(geometry.visible ~= nil) then
    geom.visible = geometry.visible
  else
    geom.visible = true
  end

  local layout = wibox.layout.fixed.horizontal()
  local wb = wibox({})
  wb:set_widget(layout)
  wb:geometry(geom)

  return {
    widgets = {},
    layout = layout,
    geom = geom,
    screen = s,
    wibox = wb,
    toggle = toggle,
    getwidth = getwidth,
    getheight = getheight,
    add = add,
    update = update
  }
end

return tray

