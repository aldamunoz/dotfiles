--- ░▀█▀░█░█░█▀▀░█▄█░█▀▀
--- ░░█░░█▀█░█▀▀░█░█░█▀▀
--- ░░▀░░▀░▀░▀▀▀░▀░▀░▀▀▀

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome"
theme.wallpaper                                 = theme.dir .. "/wallpapers/dracula-endeavour.png"

--- ░█▀▀░█▀█░█▀█░▀█▀░█▀▀
--- ░█▀▀░█░█░█░█░░█░░▀▀█
--- ░▀░░░▀▀▀░▀░▀░░▀░░▀▀▀

theme.font          = "JetBrains Mono Nerd Font 10"


--- ░█▀▀░█▀█░█░░░█▀█░█▀▄░█▀▀
--- ░█░░░█░█░█░░░█░█░█▀▄░▀▀█
--- ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀

--- Background Colors
-- https://www.nordtheme.com/docs/colors-and-palettes
theme.black = "#2e3440"
theme.black_1 = "#3b4252"
theme.black_2 = "#434c5e"
theme.black_3 = "#4c566a"
theme.transparent = "#00000000"
-- Snow Storm
theme.white = "#d8dee9"
theme.white_1 = "#e5e9f0"
theme.white_2 = "#eceff4"
-- Frost
theme.green = "#8fbcbb"
theme.cyan = "#88c0d0"
theme.blue_marine = "#81a1c1"
theme.blue = "#5e81ac"
--- Background Colors
theme.bg_normal = theme.black_3
theme.bg_focus = theme.black
theme.bg_urgent = theme.black
theme.bg_minimize = theme.black
theme.bg_systray    = theme.black

--- Foreground Colors
theme.fg_normal = theme.white_2
theme.fg_focus = theme.white


--- Wibar
theme.wibar_bg = theme.black

--- Borders
theme.border_width        = dpi(3)
theme.oof_border_width = 0
theme.border_color_marked = theme.green
theme.border_color_normal = theme.black
theme.border_color_active = theme.green
theme.border_color_new = theme.titlebar_bg
theme.border_color_urgent = theme.green
theme.border_color_floating = theme.green
theme.border_color_maximized = theme.green
theme.border_color_fullscreen = theme.green
--- Corner Radius
theme.border_radius = 40


--- Main Menu
theme.main_menu_bg = theme.lighter_black

--- Tooltip
theme.tooltip_bg = theme.lighter_black
theme.tooltip_fg = theme.white


--- Gaps
theme.useless_gap = dpi(2)

--- Systray
theme.systray_icon_size = dpi(20)
theme.systray_icon_spacing = dpi(10)
theme.bg_systray = theme.wibar_bg
--- theme.systray_max_rows = 2

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#ff0000', fg = '#ffffff' }
    }
end)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
