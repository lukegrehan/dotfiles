path = "/home/luke/.config/awesome/themes/myTheme"
theme = {}

theme.font          = "tamsyn 10"

theme.bg_normal     = "#1E1E1E"
theme.bg_focus      = "#386799"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = "3"
theme.border_normal = "#000000"
theme.border_focus  = "#386799"
theme.border_marked = "#91231c"

-- Display the taglist squares
theme.taglist_squares_sel   = path.."/taglist/squarefw.png"
theme.taglist_squares_unsel = path.."/taglist/squarew.png"

-- You can use your own command to set your wallpaper
theme.wallpaper=path.."/backgrounds/blackwood1.jpg"

-- You can use your own layout icons like this:
theme.layout_fairh = path.."/layouts/fairhw.png"
theme.layout_fairv = path.."/layouts/fairvw.png"
theme.layout_floating  = path.."/layouts/floatingw.png"
theme.layout_magnifier = path.."/layouts/magnifierw.png"
theme.layout_max = path.."/layouts/maxw.png"
theme.layout_fullscreen = path.."/layouts/fullscreenw.png"
theme.layout_tilebottom = path.."/layouts/tilebottomw.png"
theme.layout_tileleft   = path.."/layouts/tileleftw.png"
theme.layout_tile = path.."/layouts/tilew.png"
theme.layout_tiletop = path.."/layouts/tiletopw.png"
theme.layout_spiral  = path.."/layouts/spiralw.png"
theme.layout_dwindle = path.."/layouts/dwindlew.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
