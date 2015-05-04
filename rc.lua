-- Standard awesome library
local gears       = require("gears")
local awful       = require("awful")
      awful.rules = require("awful.rules")
local wibox       = require("wibox")
local beautiful   = require("beautiful")
local naughty     = require("naughty")
local keydoc      = require("keydoc")
local trayer      = require("trayer")

require("awful.autofocus")
require("eminent")


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(".config/awesome/themes/myTheme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    --awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
tags = {}
numTags = 10
for s = 1, screen.count() do
    local thisTags = {}
    for i = 1, numTags do thisTags[i] = "                " end
    tags[s] = awful.tag(thisTags, s, layouts[1])
end
-- }}}

-- {{{ Battery Warning
battery_val = "???"
battery_warn_parcent = 5
battery_warned = false

batterywidget = wibox.widget.textbox()
batterywidget:set_text(" ???% | ")

batterytimer = timer({ timeout = 15 })
batterytimer:connect_signal("timeout",
  function()
    fh = assert(io.open("/sys/class/power_supply/BAT1/capacity"))
    text = fh:read("*l")
    fh:close()
    batterywidget:set_text(" " .. text .. "% | ")

    battery_val = tonumber(text)
    if (battery_val>battery_warn_parcent) then
      battery_warned = false
    elseif(battery_val<battery_warn_parcent and not battery_warned) then
      battery_warned = true
      naughty.notify({ preset = naughty.config.presets.critical,
                    title = "low battery"})
    end
  end
)
batterytimer:start()

-- }}}

-- {{{ Wibox
statusTray = {}
promptTray = {}
promptbox = {}
taglistTray = {}
layoutBox = {}
taglist = {}
taglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ }, 3, awful.tag.viewtoggle)
                    )

for s = 1, screen.count() do
    promptbox[s] = awful.widget.prompt()
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist.buttons)
    layoutBox[s] = awful.widget.layoutbox(s)

    local taglistLayout = wibox.layout.align.horizontal()
      taglistLayout:set_middle(taglist[s])

    local statusLayout = wibox.layout.fixed.horizontal()
      statusLayout:add(batterywidget)
      statusLayout:add(awful.widget.textclock("%a %b %d, %H:%M "))
      statusLayout:add(layoutBox[s])

    promptTray[s] = trayer.new(s,promptbox[s], {
        x=(1600/2)-(200/2),
        y=(900/2),
        width=200,
        visible=false
    })

    taglistTray[s] = awful.wibox({
      position = "bottom",
      screen = s,
      height=8
    })

    statusTray[s] = trayer.new(s,statusLayout, {
      x = (1600-210),
      y=5,
      width=205
    })

    taglistTray[s]:set_widget(taglistLayout)
    statusTray[s]:toggle()
end
-- }}}

-- {{{ Key bindings
local oldSelected = {}
local hasSelection = false

globalkeys = awful.util.table.join(
    keydoc.group("Tag manipulation"),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ,"Change to left tag"),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ,"Change to right tag"),
    awful.key({ modkey,           }, "Escape", function() awful.tag.history.restore(mouse.screen) end,"Change to prev tag"),
    awful.key({ modkey,           }, "Down", function ()
      local selected = awful.tag.selectedlist(mouse.screen)
      if(not hasSelection) then
        oldSelected = selected
        hasSelection = true
      end
      awful.tag.viewnone()
    end, "Deselect all current tags"),
    awful.key({ modkey,           }, "Up", function ()
      if(hasSelection) then
        awful.tag.viewmore(oldSelected)
        oldSelected = {}
        hasSelection = false
      end
    end, "Reselect deselected tags"),

    keydoc.group("Layout manipulation"),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end,"Focus next client in stack"),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end,"Focus prev client in stack"),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,"Swap next client"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,"Swap prev client"),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end ,"Focus next screen"),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end ,"Focus prev screen"),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,"Jump to urgent"),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,"Focus prev client"),

    -- Standard program
    keydoc.group("Misc"),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end,"Spawn terminal"),
    awful.key({ modkey, "Control" }, "r", awesome.restart,"Restart awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,"Quit awesome"),

    keydoc.group("Layout manipulation"),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)
                                             naughty.notify({ title = 'Master', text = tostring(awful.tag.getnmaster()), timeout = 1 }) end,"Increase number of master windows"),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)
                                             naughty.notify({ title = 'Master', text = tostring(awful.tag.getnmaster()), timeout = 1 }) end,"Decrease number of master windows"),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)
                                             naughty.notify({ title = 'Columns', text = tostring(awful.tag.getncol()), timeout = 1 }) end,"Increase number of slave columns"),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)
                                             naughty.notify({ title = 'Columns', text = tostring(awful.tag.getncol()), timeout = 1 }) end,"Decrease number of slave columns"),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end,"Increase master window size"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end,"Decrease master window size"),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end,"Cycle layout forward"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end,"Cycle layout backward"),

    awful.key({ modkey, "Control" }, "n", awful.client.restore,"Restore client"),
    awful.key({ modkey,           }, "e", function() client.focus = awful.client.getmaster(); client.focus:raise() end,"Focus master"),

   -- Prompt
    keydoc.group("Misc"),
    awful.key({ modkey, "Shift" },            "r",     function () promptbox[mouse.screen]:run() end,"Run program"),
    awful.key({ modkey },            "r",     function ()
      local screen = mouse.screen
      local promptCont = promptTray[screen]
      promptCont:toggle()

      awful.prompt.run({prompt = "Run: "},
                promptbox[screen].widget,
                function (...)
                          local result = awful.util.spawn(...)
                          if type(result) == "string" then
                              promptbox.widget:set_text(result)
                          end
                      end,
                awful.completion.shell,
                awful.util.getdir("cache") .. "/history",
                nil,
                function() promptCont:toggle() end
      )
    end,"Run program"),

    awful.key({ }, "XF86AudioRaiseVolume", function ()
      awful.util.spawn("amixer set Master 5%+",false) end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
      awful.util.spawn("amixer set Master 5%-",false) end),
    awful.key({ }, "XF86AudioMute", function ()
      awful.util.spawn("amixer sset Master toggle",false) end),
    awful.key({ modkey }, "z", function()
      awful.util.spawn("mocp --toggle-pause",false) end),
    awful.key({ modkey }, "x", function()
      awful.util.spawn("mocp --next",false) end),

    awful.key({ }, "XF86MonBrightnessDown", function()
      awful.util.spawn("xbacklight -dec 5",false) end),
    awful.key({ }, "XF86MonBrightnessUp", function()
      awful.util.spawn("xbacklight -inc 5",false) end),

    keydoc.group("Misc"),
    awful.key({ }, "Print", function ()
      awful.util.spawn_with_shell("scrot '%M-%S.png' -e 'mv $f ~; notify-send --urgency=low Scrot took_screenshot'",false) end
      , "Take screenshot"),
    awful.key({ "Control", "Mod1" }, "l", function()
      awful.util.spawn_with_shell("xtrlock") end, "Lock screen"),

    awful.key({ modkey }, "F1", keydoc.display, "Show help")
    ,awful.key({ modkey, "Shift"   }, "n",
        function()
            local tag = awful.tag.selected()
            for i=1, #tag:clients() do
              tag:clients()[i].minimized=false
            end
        end,"Unminimise all")

    ,awful.key({ modkey }, "s",
      function()
        local toggleTray = function() statusTray[mouse.screen]:toggle() end
        local hideTimer = timer({timeout=6})
        hideTimer:connect_signal("timeout",
          function()
            toggleTray()
            hideTimer:stop()
          end)

        toggleTray()
        hideTimer:start()

      end, "Show status bar"
    )
)

clientkeys = awful.util.table.join(
    keydoc.group("Client keys"),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end,"Set client fullscreen"),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,"Close window"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,"Toggle floating"),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,"Swap client with master"),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ,"Move to screen"),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,"Set ontop"),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end,"Minimise client"),
    awful.key({ modkey, "Shift"   }, "s",
        function (c)
            c.sticky = not c.sticky
        end,"Set client sticky")
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
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
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
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

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- TODO: urgency tags
print("---")
local tag = require("awful.tag")
local hideTimer = timer({timeout=4})
local count = 10

local updateStats = function()
  local ret = {}
  ret.sel = {}
  ret.unSel = {}

  for k, t in ipairs(tag.gettags(mouse.screen)) do
    if(#t:clients() > 0) then
      if t.selected then
        table.insert(ret.sel,k)
      else 
        table.insert(ret.unSel,k)
      end
    end
  end

  return ret
end

hideTimer:connect_signal("timeout",
  function()
    local s = updateStats()
    local toPrint = "["..table.concat(s.sel, ",").."] "..table.concat(s.unSel, ",")
    print(toPrint)

    count = count - 1
    if(count == 0) then
      hideTimer:stop()
    end
  end)

hideTimer:start()

