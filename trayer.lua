local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

-- local function print( text )
--   naughty.notify({text=text})
-- end

function toggle(self)
  self.wibox.visible  = not self.wibox.visible
end

-- Module tray
local tray = {}

function tray.new(s,layout, geometry)
  local scrgeom = screen[s].workarea

  local wb = wibox({})
  wb:set_widget(layout)
  wb:geometry({
                height = geometry.height or 20,
                width = geometry.width or (wb.height * 100),
                x = geometry.x or (scrgeom.width - scrgeom.x - wibox.width),
                y = geometry.y or scrgeom.y,
              })

  if(geometry.ontop ~= nil) then
    wb.ontop = geometry.ontop
  else
    wb.ontop = true
  end

  if(geometry.visible ~= nil) then
    wb.visible = geometry.visible
  else
    wb.visible = true
  end

  return {
    screen = s,
    wibox = wb,
    toggle = toggle
  }
end


return tray

