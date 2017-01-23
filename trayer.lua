local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

--TODO:

-- Module tray
local tray = {_mt = {}}

local function debug(t)
  naughty.notify({text=tostring(t)})
end

function add(self, widget)
  self.layout:add(widget)
  self.wibox:set_widget(self.layout)
end

function tray.new(s, geometry)
  geometry = geometry or {}
  local scrgeom = screen[s].workarea
  local basex = geometry.x or (scrgeom.width - scrgeom.x - 6)
  local width = geometry.width or 270
  local geom = {
    basex = basex,
    x = basex - width,
    y = geometry.y or (scrgeom.y + 5),
    height = geometry.height or 20,
    width = width
  }

  local layout = wibox.layout.fixed.horizontal()
  local wb = wibox()
    wb:set_widget(layout)
    wb:geometry(geom)
    wb.ontop = true
    wb.visible = false


  -- local update = function(self)
  --   local width = getwidth(self)
  --   self.geom.width = width
  --   self.geom.x = self.geom.basex - width
  --   self.wibox:geometry(self.geom)
  -- end

  local self = {
    layout = layout,
    geom = geom,
    screen = s,
    wibox = wb,
    toggle = function (self) self.wibox.visible = not self.wibox.visible end,
    on = function (self) self.wibox.visible = true end,
    off = function (self) self.wibox.visible = false end,
    update = update,
    add = add,
  }

  -- update(self)

  -- layout:connect_signal("widget::updated", function() update(self) end)

  return self
end

function tray._mt:__call(...)
  return tray.new(...)
end

return setmetatable(tray, tray._mt)

