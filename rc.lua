-- Standard awesome library
local gears         = require("gears")
local awful         = require("awful")
      awful.rules   = require("awful.rules")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

require("awful.autofocus")

-- {{{ Variable definitions
beautiful.init(".config/awesome/themes/myTheme/theme.lua")

terminal = "kitty"
-- browser = "chromium"
browser = "firefox"
modkey = "Mod4"
numTags = 10

local layouts =
{
    awful.layout.suit.corner.nw,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating

}
-- }}}

-- {{{ Wallpaper
-- if beautiful.wallpaper then
--     for s = 1, screen.count() do
--         gears.wallpaper.maximized(beautiful.wallpaper, s, true)
--     end
-- end

local function set_wallpaper(s)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end
screen.connect_signal("property::geometry", set_wallpaper)

-- }}}

-- {{{ Tags
tags = {}
tagsWidget = wibox.widget.textbox()
tagsWidget:set_text("|")
function setStats()
  local screens = {}
  for s in screen do
    local text = {}
    local prev = {}

    for _, t in ipairs(s.tags) do
      if(#t:clients() > 0) then
        if t.selected then
          table.insert(prev, t.name)
        else
          if next(prev) ~= nil then
            table.insert(text, "[" .. table.concat(prev, ",") .. "]")
            prev = {}
          end
          table.insert(text, t.name)
        end
      end
    end

    if next(prev) ~= nil then
      table.insert(text, "[" .. table.concat(prev, ",") .. "]")
    end

    text = table.concat(text, ",")
    table.insert(screens, text)
  end

  if #screens > 1 then
    local focused = awful.screen.focused().index
    screens[focused] = "'" .. screens[focused]
  end

  local res = "<"..table.concat(screens, "> <").."> | "
  if #screens == 1 then
    res = res:sub(2, -5) .. " | "
  end
  tagsWidget:set_text(res)
end


-- }}}

-- {{{ Battery Warning
battery_cmd = 'cat /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT1/capacity'
battery_warn_parcent = 15
battery_warned = false

batterywidget = awful.widget.watch(battery_cmd, 5, function(widget, stdout, stderr, exitreason, exitcode)
  battery_val = tonumber(stdout)
  widget:set_text(" " .. tostring(battery_val) .. "% | ")

  if (battery_val > battery_warn_parcent) then
    battery_warned = false
  elseif (battery_val < battery_warn_parcent and not battery_warned) then
    battery_warned = true
    naughty.notify({ preset = naughty.config.presets.critical
                   , title = "low battery"
                   })
  end

end)

-- {{{ Wibox
statusTray = {}
statusTrayTimers = {}

function showTray()
  local screen = awful.screen.focused()

  local st = statusTray[screen]
  st.visible = true

  local timer = statusTrayTimers[screen]
  if (timer ~= nil) then
    timer:stop()
  end

  statusTrayTimers[screen] = gears.timer.start_new(6, function()
    st.visible = false
    statusTrayTimers[screen] = nil
    return false
  end)
end

-- }}}

-- {{{ Master/slave info
-- TODO: make dynamic?
function showColInfo()
  local master = tostring(awful.tag.getnmaster())
  local col = tostring(awful.tag.getncol())
  local mw = tostring(awful.tag.getmwfact())
  local text = "<b>Master: </b>" .. master
          .. "\n<b>Cols: </b>" .. col
          .. "\n<b>Master width: </b>" .. mw

  local p = awful.popup {
    widget = {
      {
        {
          markup = text,
          widget = wibox.widget.textbox
        },
        layout = wibox.layout.fixed.horizontal,
      },
      margins = 10,
      widget  = wibox.container.margin,
      forced_width = 155,
    },
    border_color = beautiful.border_focus,
    border_width = beautiful.border_width,
    placement    = awful.placement.top_left,
    shape        = gears.shape.rounded_rect,
    visible      = true,
    ontop        = true,
    hide_on_right_click = true,
    screen = awful.screen.focused(),
  }

  gears.timer.start_new(3, function()
    p.visible = false
    return false
  end)

end
-- }}}

awful.screen.connect_for_each_screen(function(s)
  set_wallpaper(s)

  local thisTags = {}
  for i = 1,numTags do thisTags[i] = i end
  awful.tag(thisTags, s, layouts[1])

  statusTray[s] = awful.popup {
    widget = {
      {
        batterywidget,
        tagsWidget,
        wibox.widget.textclock("%a %b %d, %H:%M "),
        wibox.widget {
          awful.widget.layoutbox(s),
          layout = wibox.layout.fixed.horizontal,
          forced_height = 15,
          forced_width = 15
        },
        layout = wibox.layout.fixed.horizontal,
      },
      margins = 5,
      widget  = wibox.container.margin
    },
    border_color = beautiful.border_focus,
    border_width = beautiful.border_width,
    placement    = awful.placement.top_right,
    shape        = gears.shape.rounded_rect,
    visible      = false,
    ontop        = true,
    hide_on_right_click = true,
    screen = s
  }

  for _, prop in ipairs({ "property::selected", "property::name",
    "property::activated", "property::screen", "property::index" }) do
    awful.tag.attached_connect_signal(s, prop, setStats)
  end
end)

client.connect_signal("focus"   , setStats)
client.connect_signal("unfocus" , setStats)
client.connect_signal("tagged"  , setStats)
client.connect_signal("untagged", setStats)


-- {{{ Key bindings
local oldSelected = {}
local hasSelection = false

globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ,{description = "Change to left tag", group = "Tag Manipulation"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ,{description = "Change to right tag", group = "Tag Manipulation"}),
    awful.key({ modkey,           }, "Escape", function() awful.tag.history.restore(mouse.screen) end,{description = "Change to prev tag", group = "Tag Manipulation"}),
    awful.key({ modkey,           }, "Down", function ()
      local selected = awful.tag.selectedlist(mouse.screen)
      if(not hasSelection) then
        oldSelected = selected
        hasSelection = true
      end
      awful.tag.viewnone()
    end, {description = "Deselect all current tags", group = "Tag Manipulation"}),
    awful.key({ modkey,           }, "Up", function ()
      if(hasSelection) then
        awful.tag.viewmore(oldSelected)
        oldSelected = {}
        hasSelection = false
      end
    end, {description = "Reselect deselected tags", group = "Tag Manipulation"}),


    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end,{description = "Focus next client in stack", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end,{description = "Focus prev client in stack", group = "Layout Manipulation"}),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,{description = "Swap next client", group = "Layout Manipulation"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,{description = "Swap prev client", group = "Layout Manipulation"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1); showTray() end ,{description = "Focus next screen", group = "Layout Manipulation"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1); showTray() end ,{description = "Focus prev screen", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,{description = "Jump to urgent", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,{description = "Focus prev client", group = "Layout Manipulation"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal, {screen = awful.screen.focused({client=true})}) end,{description = "Spawn terminal", group = "Misc"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,{description = "Restart awesome", group = "Misc"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,{description = "Quit awesome", group = "Misc"}),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1); showColInfo() end,{description = "Increase number of master windows", group = "Layout Manipulation"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1); showColInfo() end,{description = "Decrease number of master windows", group = "Layout Manipulation"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1); showColInfo() end,{description = "Increase number of slave columns", group = "Layout Manipulation"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1); showColInfo() end,{description = "Decrease number of slave columns", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.025); showColInfo() end,{description = "Increase master window size", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.025); showColInfo() end,{description = "Decrease master window size", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end,{description = "Cycle layout forward", group = "Layout Manipulation"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end,{description = "Cycle layout backward", group = "Layout Manipulation"}),

    awful.key({ modkey, "Control" }, "n", awful.client.restore,{description = "Restore client", group = "Layout Manipulation"}),
    awful.key({ modkey, "Shift"   }, "e", function() client.focus = awful.client.getmaster(); client.focus:raise() end,{description = "Focus master", group = "Layout Manipulation"}),
    awful.key({ modkey,           }, "e", function() awful.spawn("rofimoji -a clipboard") end,{description = "Copy emoji", group = "Misc"}),

   -- Prompt
    awful.key({ modkey }, "r", function () awful.spawn(browser) end, {description = "Run browser", group = "Misc"}),
    awful.key({ modkey, "Shift" }, "r", function () awful.spawn("rofi -show run") end, {description = "Run program", group = "Misc"}),
    awful.key({ modkey }, "p", function () awful.spawn("passmenu") end, {description = "Run passmenu", group = "Misc"}),

    awful.key({ }, "XF86AudioRaiseVolume", function ()
      awful.spawn("amixer set Master 5%+",false) end,{description = "raise volume", group = "Sound"} ),
    awful.key({ }, "XF86AudioLowerVolume", function ()
      awful.spawn("amixer set Master 5%-",false) end,{description = "lower volume", group = "Sound"}),
    awful.key({ }, "XF86AudioMute", function ()
      awful.spawn("amixer sset Master toggle",false) end,{description = "mute", group = "Sound"}),
    awful.key({ modkey }, "z", function()
      awful.spawn("mocp --toggle-pause",false) end,{description = "pause music", group = "Sound"}),
    awful.key({ modkey }, "x", function()
      awful.spawn("mocp --next",false) end,{description = "next song", group = "Sound"}),

    awful.key({ }, "XF86Display", function ()
      awful.spawn("arandr") end,{description = "Screen setup", group = "Screens"}),

    awful.key({ }, "XF86MonBrightnessDown", function()
      awful.spawn("xbacklight -dec 5",false) end,{description = "decrease brightness", group = "Misc"}),
    awful.key({ }, "XF86MonBrightnessUp", function()
      awful.spawn("xbacklight -inc 5",false) end,{description = "increase brightness", group = "Misc"}),

    awful.key({ }, "Print", function ()
      awful.util.spawn_with_shell("scrot '%M-%S.png' -e 'mv $f ~; notify-send --urgency=low Scrot took_screenshot'",false) end
      , {description = "Take screenshot", group = "Misc"}),
    awful.key({ "Control", "Mod1" }, "l", function() awful.spawn("xtrlock") end, {description = "Lock screen", group = "Misc"}),

    awful.key({ modkey }, "F1", hotkeys_popup.show_help, {description = "Show help (...so meta)", group = "Misc"}),
    awful.key({ modkey }, "F2", showColInfo, {description = "Show col info", group = "Misc"}),
    awful.key({ modkey }, "s", showTray, {description = "Show status bar", group = "Misc"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "q",      function (c) c:kill()                             end,{description = "Close window", group = "Client"}),
    awful.key({ modkey, "Control" }, "space",               awful.client.floating.toggle            ,{description = "Toggle floating", group = "Client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster())     end,{description = "Swap client with master", group = "Client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()                   end,{description = "Move to next screen", group = "Client"}),
    awful.key({ modkey, "Shift"   }, "o",      function (c) c:move_to_screen(c.screen.index-1)   end,{description = "Move to prev screen", group = "Client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop                end,{description = "Set ontop", group = "Client"}),
    awful.key({ modkey,           }, "m",      function (c) c.fullscreen = not c.fullscreen      end,{description = "Maximize client", group = "Client"}),
    awful.key({ modkey, "Shift"   }, "s",      function (c) c.sticky = not c.sticky              end,{description = "Set client sticky", group = "Client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, numTags do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end, {description = "View only tag " .. i, group = "Tag Manipulation"}),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end, {description = "View tag " .. i, group = "Tag Manipulation"}),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end, {description = "Move window to tag " .. i, group = "Tag Manipulation"}),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end, {description = "Toggle tag " .. i .. " on window", group = "Tag Manipulation"}))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     screen = awful.screen.preferred,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
                   } },
    { rule_any = {
        instance = {"pinentry", "blueberry.py"},
        name = {"Event Tester"},
        class = {"gimp", "Peek", "Blueman-manager"},
        role = {"pop-up"}
      }, properties = { floating = true, placement=awful.placement.centered }},
    { rule = { instance="umpv" },
      properties = { tag = "1" }
    }

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

tag.connect_signal("property::selected", function(t)
  showTray()
end)

-- }}}
