local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

function toggle(self)
  self.wibox.visible  = not self.wibox.visible
end

-- Module tray
local tray = {}

function getwidth(self)
  local function getW(widget)
    local w,_ = widget:fit(1000, self.geom.height)
    return w
  end

  local w = 0
  for _,v in ipairs(self.widgets) do
    w = w + getW(v)
  end

  return w
end

function add(self, widget)
  table.insert(self.widgets, widget)
  self.layout:add(widget)
  self.wibox:set_widget(self.layout)
end

function tray.new(s, geometry)
  geometry = geometry or {}
  local scrgeom = screen[s].workarea
  local basex = geometry.x or (scrgeom.width - scrgeom.x - 6)
  local geom = {
    basex = basex,
    x = basex,
    y = geometry.y or (scrgeom.y + 5),
    height = geometry.height or 20
  }

  if (geometry.width ~= nil) then
    -- given a fixed width
    geom.width = geometry.width
    local update = function() end --never update width
  end

  local layout = wibox.layout.fixed.horizontal()
  local wb = wibox({})
    wb:set_widget(layout)
    wb:geometry(geom)
    wb.ontop = true

  if(geometry.visible ~= nil) then
    wb.visible = geometry.visible
  else
    wb.visible = false
  end

  local self = {
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

  layout:connect_signal("widget::updated", function()
    local width = self:getwidth()
    self.geom.width = width
    self.geom.x = self.geom.basex - width
    self.wibox:geometry(self.geom)
  end)

  return self
end

return tray

