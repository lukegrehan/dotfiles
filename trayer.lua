local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

-- Module tray
local tray = {_mt = {}}

local function debug(t)
  naughty.notify({text=t})
end

-- function getwidth(self)
--   local total = 0
--   for _,v in ipairs(self.layout.children) do
--     -- local w,_ = v:fit(1000, self.geom.height)
--     local w = v:get_forced_width()
--     -- debug("?"..w)
--     total = total + w
--   end

--   return total
-- end

function add(self, widget)
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

  local doUpdate = true
  if (geometry.width ~= nil) then
    -- given a fixed width
    geom.width = geometry.width
    geom.x = geom.basex - geom.width
    doUpdate = false
  end

  local layout = wibox.layout.fixed.horizontal()
  local wb = wibox({})
    wb:set_widget(wibox.container.constraint(layout,'min'))
    wb:geometry(geom)
    wb.ontop = true

  if(geometry.visible ~= nil) then
    wb.visible = geometry.visible
  else
    wb.visible = false
  end

  local update = function(self)
    if doUpdate then
      local width = getwidth(self)
      self.geom.width = width
      self.geom.x = self.geom.basex - width
      self.wibox:geometry(self.geom)
    end
  end

  local self = {
    layout = layout,
    geom = geom,
    screen = s,
    wibox = wb,
    toggle = function (self) self.wibox.visible  = not self.wibox.visible end,
    on = function (self) self.wibox.visible = true end,
    off = function (self) self.wibox.visible = false end,
    -- update = update,
    add = add,
  }

  layout:connect_signal("widget::updated", function() update(self) end)

  return self
end

function tray._mt:__call(...)
  return tray.new(...)
end

return setmetatable(tray, tray._mt)

