-- {{{ Header
--
-- Awesome configuration, using awesome 3.4-rc1 on Arch GNU/Linux
--   * Adrian C. <anrxc.sysphere.org>

-- Screenshot: http://sysphere.org/gallery/snapshots

-- This work is licensed under the Creative Commons Attribution Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- {{{ Libraries
require("awful")
require("awful.rules")
require("awful.autofocus")
-- User libraries
require("vicious")
require("teardrop")
-- }}}


-- {{{ Variable definitions
--
-- Custom theme
beautiful.init(awful.util.getdir("config") .. "/zenburn.lua")

-- Modifier keys
altkey = "Mod1" -- Alt_L
modkey = "Mod4" -- Super_L

-- Window management layouts
layouts = {
    awful.layout.suit.tile,            -- 1
    awful.layout.suit.tile.left,       -- 2
    awful.layout.suit.tile.bottom,     -- 3
    awful.layout.suit.tile.top,        -- 4
    awful.layout.suit.fair,            -- 5
    awful.layout.suit.fair.horizontal, -- 6
    awful.layout.suit.max,             -- 7
    awful.layout.suit.magnifier,       -- 8
    awful.layout.suit.floating         -- 9
}
-- }}}


-- {{{ Tags
tags = {}
tags.settings = {
    { name = "term",  layout = layouts[2]  },
    { name = "emacs", layout = layouts[1]  },
    { name = "web",   layout = layouts[1]  },
    { name = "mail",  layout = layouts[7]  },
    { name = "im",    layout = layouts[1], mwfact = 0.13 },
    { name = "6",     layout = layouts[9], hide = true },
    { name = "7",     layout = layouts[9], hide = true },
    { name = "rss",   layout = layouts[8]  },
    { name = "media", layout = layouts[9]  }
}

for s = 1, screen.count() do
    tags[s] = {}
    for i, v in ipairs(tags.settings) do
        tags[s][i] = tag({ name = v.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
        awful.tag.setproperty(tags[s][i], "hide",   v.hide)
    end
    tags[s][1].selected = true
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separators
spacer         = widget({ type = "textbox", name = "spacer" })
separator      = widget({ type = "textbox", name = "separator" })
spacer.text    = " "
separator.text = "|"
-- }}}

-- {{{ CPU usage and temperature
-- Widget icon
cpuicon        = widget({ type = "imagebox", name = "cpuicon" })
cpuicon.image  = image(beautiful.widget_cpu)
-- Initialize widgets
thermalwidget  = widget({ type = "textbox", name = "thermalwidget" })
cpuwidget      = awful.widget.graph({ layout = awful.widget.layout.horizontal.rightleft })
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_scale(false)
cpuwidget:set_max_value(100)
cpuwidget:set_background_color(beautiful.fg_off_widget)
cpuwidget:set_border_color(beautiful.border_widget)
cpuwidget:set_color(beautiful.fg_end_widget)
cpuwidget:set_gradient_colors({
    beautiful.fg_end_widget,
    beautiful.fg_center_widget,
    beautiful.fg_widget })
-- Register widgets
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 2)
vicious.register(thermalwidget, vicious.widgets.thermal, "$1°C", 60, "TZS0")
-- }}}

-- {{{ Battery state
-- Widget icon
baticon       = widget({ type = "imagebox", name = "baticon" })
baticon.image = image(beautiful.widget_bat)
-- Initialize widget
batwidget     = widget({ type = "textbox", name = "batwidget" })
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 60, "BAT0")
-- }}}

-- {{{ Memory usage
-- Widget icon
memicon       = widget({ type = "imagebox", name = "memicon" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
memwidget     = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- Pogressbar properties
memwidget:set_width(8)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color(beautiful.fg_off_widget)
memwidget:set_border_color(nil)
memwidget:set_color(beautiful.fg_widget)
memwidget:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget })
awful.widget.layout.margins[memwidget.widget] = { top = 2, bottom = 2 }
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1", 60)
-- }}}

-- {{{ File system usage
-- Widget icon
fsicon       = widget({ type = "imagebox", name = "fsicon" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widgets
fswidget = {
    ["root"]    = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    ["home"]    = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    ["storage"] = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    ["backup"]  = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft }),
    -- Configure widgets
    margins = {
        top = 1, bottom = 1
    },
    settings = {
        width = 5, height = 12, vertical = true
    },
    colors = {
        border    = beautiful.border_widget,
        bg        = beautiful.fg_off_widget,
        fg        = beautiful.fg_widget,
        fg_center = beautiful.fg_center_widget,
        fg_end    = beautiful.fg_end_widget
}}
-- Progressbar properties
for _, w in pairs(fswidget) do
    if w.widget ~= nil then
        w:set_width(fswidget.settings.width)
        w:set_height(fswidget.settings.height)
        w:set_vertical(fswidget.settings.vertical)
        w:set_background_color(fswidget.colors.bg)
        w:set_border_color(fswidget.colors.border)
        w:set_color(fswidget.colors.fg)
        w:set_gradient_colors({
            fswidget.colors.fg,
            fswidget.colors.fg_center,
            fswidget.colors.fg_end
        })
        awful.widget.layout.margins[w.widget] = fswidget.margins
        -- Register buttons
        w.widget:buttons(awful.util.table.join(
            awful.button({ }, 1, function () awful.util.spawn("rox", false) end)
        ))
    end
end
-- Register widgets
vicious.register(fswidget["root"],    vicious.widgets.fs, "${/ usep}",            240)
vicious.register(fswidget["home"],    vicious.widgets.fs, "${/home usep}",        240)
vicious.register(fswidget["storage"], vicious.widgets.fs, "${/mnt/storage usep}", 240)
vicious.register(fswidget["backup"],  vicious.widgets.fs, "${/mnt/backup usep}",  240)
-- }}}

-- {{{ Network usage
-- Widget icons
neticon         = widget({ type = "imagebox", name = "neticon" })
neticonup       = widget({ type = "imagebox", name = "neticonup" })
neticon.image   = image(beautiful.widget_net)
neticonup.image = image(beautiful.widget_netup)
-- Initialize widgets
netwidget       = widget({ type = "textbox", name = "netwidget" })
netfiwidget     = widget({ type = "textbox", name = "netfiwidget" })
-- Register ethernet widget
vicious.register(netwidget, vicious.widgets.net,
  '<span color="'.. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 2)
-- Register wireless widget
vicious.register(netfiwidget, vicious.widgets.net,
  '<span color="'.. beautiful.fg_netdn_widget ..'">${wlan0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${wlan0 up_kb}</span>', 2)
-- }}}

-- {{{ Mail subject
-- Widget icon
mailicon       = widget({ type = "imagebox", name = "mailicon" })
mailicon.image = image(beautiful.widget_mail)
-- Initialize widget
mboxwidget     = widget({ type = "textbox", name = "mboxwidget" })
-- Register widget
vicious.register(mboxwidget, vicious.widgets.mbox, "$1", 60, "/home/anrxc/mail/Inbox")
-- Register buttons
mboxwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.util.spawn("urxvt -title Alpine -e alpine_exp", false) end)))
-- }}}

-- {{{ Org-mode agenda
-- Widget icon
orgicon       = widget({ type = "imagebox", name = "orgicon" })
orgicon.image = image(beautiful.widget_org)
-- Initialize widget
orgwidget     = widget({ type = "textbox", name = "orgwidget" })
-- Configure widget
orgmode = {
    files  = {
      os.getenv("HOME") .. "/.org/work.org",     os.getenv("HOME") .. "/.org/index.org",
      os.getenv("HOME") .. "/.org/personal.org", os.getenv("HOME") .. "/.org/computers.org"
    },
    colors = {
      past   = '<span color="'..beautiful.fg_urgent..'">',
      today  = '<span color="'..beautiful.fg_normal..'">',
      soon   = '<span color="'..beautiful.fg_widget..'">',
      future = '<span color="'..beautiful.fg_netup_widget..'">'
}}
-- Register widget
vicious.register(orgwidget, vicious.widgets.org, 
     orgmode.colors.past .. '$1</span>|' .. orgmode.colors.today  .. '$2</span>|' ..
     orgmode.colors.soon .. '$3</span>|' .. orgmode.colors.future .. '$4</span>',
     240, orgmode.files)
-- Register buttons
orgwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function ()
      awful.util.spawn("emacsclient --eval '(org-agenda-list)'", false)
  end),
  awful.button({ }, 3, function ()
      awful.util.spawn("emacsclient --eval '(make-remember-frame)'", false)
  end)))
-- }}}

-- {{{ Volume level
-- Widget icon
volicon       = widget({ type = "imagebox", name = "volicon" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volwidget     = widget({ type = "textbox", name = "volwidget" })
volbarwidget  = awful.widget.progressbar({ layout = awful.widget.layout.horizontal.rightleft })
-- Progressbar properties
volbarwidget:set_width(8)
volbarwidget:set_height(10)
volbarwidget:set_vertical(true)
volbarwidget:set_background_color(beautiful.fg_off_widget)
volbarwidget:set_border_color(nil)
volbarwidget:set_color(beautiful.fg_widget)
volbarwidget:set_gradient_colors({
    beautiful.fg_widget,
    beautiful.fg_center_widget,
    beautiful.fg_end_widget })
awful.widget.layout.margins[volbarwidget.widget] = { top = 2, bottom = 2 }
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "PCM")
vicious.register(volbarwidget, vicious.widgets.volume, "$1", 2, "PCM")
-- Register buttons
volbarwidget.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("kmix", false) end),
    awful.button({ }, 2, function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q sset PCM 2dB+", false) end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q sset PCM 2dB-", false) end)
))  volwidget:buttons( volbarwidget.widget:buttons() )
-- }}}

-- {{{ Date and time
-- Widget icon
dateicon       = widget({ type = "imagebox", name = "dateicon" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget     = widget({ type = "textbox", name = "datewidget" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%b %e, %R", 60)
-- Register buttons
datewidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("pylendar.py", false) end)))
-- }}}

-- {{{ System tray
systray = widget({ type = "systray" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
wibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev))

for s = 1, screen.count() do
    -- Create a promptbox
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({
        position = "top", height = 14, screen = s,
        fg = beautiful.fg_normal, bg = beautiful.bg_normal
    })
    -- Add widgets to the wibox
    wibox[s].widgets = {{
        taglist[s],
        layoutbox[s],
        promptbox[s],
        layout = awful.widget.layout.horizontal.leftright
    },
        s == screen.count() and systray or nil,
        separator,
        datewidget, dateicon,
        separator,
        volwidget, spacer, volbarwidget.widget, volicon,
        separator,
        spacer, orgwidget, orgicon,
        separator,
        mboxwidget, spacer, mailicon,
        separator,
        neticonup, netfiwidget, neticon,
        separator,
        neticonup, netwidget, neticon,
        separator,
        fswidget["backup"].widget, fswidget["storage"].widget,
        fswidget["home"].widget, fswidget["root"].widget, fsicon,
        separator,
        spacer, memwidget.widget, spacer, memicon,
        separator,
        spacer, batwidget, baticon,
        separator,
        cpuwidget.widget, spacer, thermalwidget, cpuicon,
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Client mouse bindings
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}


-- {{{ Key bindings
--
-- {{{ Global keys
globalkeys = awful.util.table.join(
    -- {{{ Applications
    awful.key({ modkey }, "e", function () awful.util.spawn("emacsclient -n -c", false) end),
    awful.key({ modkey }, "r", function () awful.util.spawn("rox", false) end),
    awful.key({ modkey }, "u", function () awful.util.spawn("utorrent", false) end),
    awful.key({ modkey }, "w", function () awful.util.spawn("firefox", false) end),
    awful.key({ altkey }, "F1",  function () awful.util.spawn("urxvt", false) end),
    awful.key({ altkey }, "#49", function () teardrop("urxvt", "bottom") end),
    awful.key({ modkey }, "F2",  function () teardrop("gmrun", nil, nil, nil, 0.08) end),
    awful.key({ modkey }, "a", function ()
        awful.util.spawn("urxvt -title Alpine -e alpine_exp", false)
    end),
    awful.key({ modkey }, "g", function ()
        awful.util.spawn_with_shell("GTK2_RC_FILES=~/.gtkrc-gajim gajim", false)
    end),
    awful.key({ modkey }, "q", function ()
        awful.util.spawn("emacsclient --eval '(make-remember-frame)'", false)
    end),
    -- }}}

    -- {{{ Multimedia keys
    awful.key({}, "#160", function () awful.util.spawn("kscreenlocker --forcelock", false) end),
    awful.key({}, "#146", function () awful.util.spawn("khelpcenter", false) end),
    awful.key({}, "#121", function () awful.util.spawn("pvol.py -m", false) end),
    awful.key({}, "#122", function () awful.util.spawn("pvol.py -p -c -2", false) end),
    awful.key({}, "#123", function () awful.util.spawn("pvol.py -p -c 2", false) end),
    awful.key({}, "#232", function () awful.util.spawn("plight.py -s -a", false) end),
    awful.key({}, "#233", function () awful.util.spawn("plight.py -s -a", false) end),
    awful.key({}, "#244", function () awful.util.spawn("sudo /usr/sbin/pm-hibernate", false) end),
    awful.key({}, "#150", function () awful.util.spawn("sudo /usr/sbin/pm-suspend", false) end),
    awful.key({}, "#156", function () awful.util.spawn("emacsclient -n -c", false) end),
    awful.key({}, "#225", function () awful.util.spawn("pypres.py", false) end),
    awful.key({}, "#181", function () awful.util.spawn("xrefresh", false) end),
    awful.key({}, "#180", function () awful.util.spawn("firefox -browser", false) end),
    awful.key({}, "#163", function () awful.util.spawn("urxvt -title Alpine -e alpine", false) end),
    awful.key({}, "#157", function () awful.util.spawn("geeqie", false) end),
    awful.key({}, "Print",function () awful.util.spawn("ksnapshot", false) end),
    -- }}}

    -- {{{ Prompt menus
    awful.key({ altkey }, "F2", function ()
        awful.prompt.run({ prompt = "Run: " }, promptbox[mouse.screen].widget,
            function (...) promptbox[mouse.screen].text = awful.util.spawn(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ altkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, promptbox[mouse.screen].widget,
            function (words)
                local xmessage = "xmessage -timeout 10 -file -"
                awful.util.spawn_with_shell("crodict " .. words .. " | " .. xmessage, false)
            end)
    end),
    awful.key({ altkey }, "F4", function ()
        awful.prompt.run({ prompt = "Manual: " }, promptbox[mouse.screen].widget,
            function (page) awful.util.spawn("urxvt -e man " .. page, false) end)
    end),
    awful.key({ altkey }, "F5", function ()
        awful.prompt.run({ prompt = "Run Lua code: " }, promptbox[mouse.screen].widget,
        awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
    end),
    awful.key({ altkey }, "F10", function ()
        awful.prompt.run({ prompt = "Connect: " }, promptbox[mouse.screen].widget,
            function (host) awful.util.spawn("urxvt -e ssh " .. host, false) end)
    end),
    awful.key({ altkey }, "F11", function ()
        awful.prompt.run({ prompt = "Calculate: " }, promptbox[mouse.screen].widget,
            function (expr)
                local xmessage = "xmessage -timeout 10 -file -"
                awful.util.spawn_with_shell("echo '" .. expr .. ' = ' ..
                  awful.util.eval("return (" .. expr .. ")") .. "' | " .. xmessage, false)
            end)
    end),
    awful.key({ altkey }, "F12", function ()
        awful.prompt.run({ prompt = "Web search: " }, promptbox[mouse.screen].widget,
            function (command)
                awful.util.spawn("firefox 'http://yubnub.org/parser/parse?command="..command.."'", false)
                if tags[mouse.screen][3] then awful.tag.viewonly(tags[mouse.screen][3]) end
            end)
    end),
    -- }}}

    -- {{{ Awesome controls
    awful.key({ modkey, "Shift" }, "m", function () awful.mouse.finder():find() end),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "r", function ()
        promptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
    end),
    -- }}}

    -- {{{ Tag browsing
    awful.key({ altkey }, "n",      awful.tag.viewnext),
    awful.key({ altkey }, "p",      awful.tag.viewprev),
    awful.key({ altkey }, "Escape", awful.tag.history.restore),
    -- }}}

    -- {{{ Layout manipulation
    awful.key({ modkey }, "l",          function () awful.tag.incmwfact(0.05) end),
    awful.key({ modkey }, "h",          function () awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "l", function () awful.client.incwfact(-0.05) end),
    awful.key({ modkey, "Shift" }, "h", function () awful.client.incwfact(0.05) end),
    awful.key({ modkey }, "space",          function () awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),
    awful.key({ altkey, "Shift" }, "l",     function () awful.tag.incnmaster(-1) end),
    awful.key({ altkey, "Shift" }, "h",     function () awful.tag.incnmaster(1) end),
    awful.key({ modkey, "Control" }, "l",   function () awful.tag.incncol(-1) end),
    awful.key({ modkey, "Control" }, "h",   function () awful.tag.incncol(1) end),
    -- }}}

    -- {{{ Focus controls
    awful.key({ modkey }, "p", function () awful.screen.focus_relative(1) end),
    awful.key({ modkey }, "s", function ()
        for k, c in pairs(client.get(mouse.screen)) do
            if c.minimized then
                awful.client.movetotag(awful.tag.selected(mouse.screen), c)
                awful.client.floating.set(c, true)
                awful.placement.centered(c)
                c.minimized = false
                c:raise(); client.focus = c
            end
        end
    end),
    awful.key({ altkey }, "Tab", awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab", function ()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "j", function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "k", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#48", function ()
        awful.client.focus.bydirection("down")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#34", function ()
        awful.client.focus.bydirection("up")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#47", function ()
        awful.client.focus.bydirection("left")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#51", function ()
        awful.client.focus.bydirection("right")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift" }, "j",   function () awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "k",   function () awful.client.swap.byidx(-1) end),
    awful.key({ modkey, "Shift" }, "#48", function () awful.client.swap.bydirection("down") end),
    awful.key({ modkey, "Shift" }, "#34", function () awful.client.swap.bydirection("up") end),
    awful.key({ modkey, "Shift" }, "#47", function () awful.client.swap.bydirection("left") end),
    awful.key({ modkey, "Shift" }, "#51", function () awful.client.swap.bydirection("right") end)
    -- }}}
)
-- }}}

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
    awful.key({ modkey }, "b", function ()
        if wibox[mouse.screen].screen == nil then
             wibox[mouse.screen].screen = mouse.screen
        else wibox[mouse.screen].screen = nil end
    end),
    awful.key({ modkey }, "c", function (c) c:kill() end),
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),
    awful.key({ modkey }, "o",     awful.client.movetoscreen),
    awful.key({ modkey }, "Next",  function () awful.client.moveresize(20, 20, -20, -20) end),
    awful.key({ modkey }, "Prior", function () awful.client.moveresize(-20, -20, 20, 20) end),
    awful.key({ modkey }, "Down",  function () awful.client.moveresize(0, 20, 0, 0) end),
    awful.key({ modkey }, "Up",    function () awful.client.moveresize(0, -20, 0, 0) end),
    awful.key({ modkey }, "Left",  function () awful.client.moveresize(-20, 0, 0, 0) end),
    awful.key({ modkey }, "Right", function () awful.client.moveresize(20, 0, 0, 0) end),
    awful.key({ modkey },          "d", function (c) c.minimized = not c.minimized end),
    awful.key({ modkey, "Shift" }, "0", function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift" }, "o", function (c) c.ontop = not c.ontop end),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, { modkey = modkey }) end
    end),
    awful.key({ modkey, "Control" }, "r",     function (c) c:redraw() end),
    awful.key({ modkey, "Control" }, "space", function (c)
        awful.client.floating.toggle(c)
        if awful.client.floating.get(c) then
             c.above = true;  awful.titlebar.add(c)
        else c.above = false; awful.titlebar.remove(c) end
    end),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift" }, "c", function (c) awful.util.spawn("kill -CONT "..c.pid, false) end),
    awful.key({ modkey, "Shift" }, "s", function (c) awful.util.spawn("kill -STOP "..c.pid, false) end)
)
-- }}}

-- {{{ Keyboard digits
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- }}}

-- {{{ Tag controls
for i = 1, keynumber do
    globalkeys = awful.util.table.join( globalkeys,
        awful.key({ modkey }, i, function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end),
        awful.key({ modkey, "Control" }, i, function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewtoggle(tags[screen][i])
            end
        end),
        awful.key({ modkey, "Shift" }, i, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end),
        awful.key({ modkey, "Control", "Shift" }, i, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.toggletag(tags[client.focus.screen][i])
            end
        end))
end
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
    { rule = { },
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus = true,
          keys = clientkeys,
          buttons = clientbuttons
    }},
    { rule = { name = "Alpine" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Gajim.py" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Knode" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Akregator" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Firefox" },
      properties = { tag = tags[screen.count()][3] } },
    { rule = { class = "Emacs", instance = "emacs" },
      properties = { tag = tags[screen.count()][2] } },
    { rule = { class = "Emacs", instance = "_Remember_" },
      properties = { floating = true } },
    { rule = { class = "Xmessage", instance = "xmessage" },
      properties = { floating = true } },
    { rule = { class = "ROX-Filer" },
      properties = { floating = true } },
    { rule = { class = "Ark" },
      properties = { floating = true } },
    { rule = { class = "Geeqie" },
      properties = { floating = true } },
    { rule = { class = "Pinentry-gtk-2" },
      properties = { floating = true } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Signal function to execute when a new client appears
client.add_signal("manage", function (c, startup)
    -- Add a titlebar to each floating client
    if awful.client.floating.get(c) or
        awful.layout.get(c.screen) == awful.layout.suit.floating
    then
        if not c.titlebar and c.class ~= "Xmessage" then
            awful.titlebar.add(c, { modkey = modkey })
        end
        -- Floating clients are always on top
        c.above = true
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function (c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
           and awful.client.focus.filter(c) then
               client.focus = c
        end
    end)

    -- Client placement
    awful.client.setslave(c)
    awful.placement.no_offscreen(c)

    -- Honor size hints
    c.size_hints_honor = false
end)
-- }}}

-- {{{ Focus signal functions
client.add_signal("focus",   function (c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
-- }}}
-- }}}
