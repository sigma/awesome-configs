-- {{{ License
--
-- Awesome configuration, using awesome 3.4 on Arch GNU/Linux
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
require("scratchpad")
-- }}}


-- {{{ Variable definitions
--
-- Beautiful theme
beautiful.init(awful.util.getdir("config") .. "/zenburn.lua")

-- Modifier keys
local altkey = "Mod1" -- Alt_L
local modkey = "Mod4" -- Super_L

-- Function aliases
local exec  = awful.util.spawn
local sexec = awful.util.spawn_with_shell

-- Window management layouts
local layouts = {
    awful.layout.suit.tile,        -- 1
    awful.layout.suit.tile.left,   -- 2
    awful.layout.suit.tile.bottom, -- 3
    awful.layout.suit.tile.top,    -- 4
    awful.layout.suit.max,         -- 5
    awful.layout.suit.magnifier,   -- 6
    awful.layout.suit.floating     -- 7
}
-- }}}


-- {{{ Tags
local tags = {}
tags.setup = {
    { name = "term",  layout = layouts[3]  },
    { name = "emacs", layout = layouts[1]  },
    { name = "web",   layout = layouts[1]  },
    { name = "mail",  layout = layouts[5]  },
    { name = "im",    layout = layouts[1], mwfact = 0.13 },
    { name = "6",     layout = layouts[7], hide   = true },
    { name = "7",     layout = layouts[7], hide   = true },
    { name = "rss",   layout = layouts[6]  },
    { name = "media", layout = layouts[7]  }
}

for s = 1, screen.count() do
    tags[s] = {}
    for i, t in ipairs(tags.setup) do
        tags[s][i] = tag({ name = t.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", t.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", t.mwfact)
        awful.tag.setproperty(tags[s][i], "hide",   t.hide)
    end
    tags[s][1].selected = true
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separators
local spacer    = widget({ type = "textbox" })
local separator = widget({ type = "textbox" })
spacer.text     = " "
separator.text  = "|"
-- }}}

-- {{{ CPU usage and temperature
local cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- Initialize widgets
local tzswidget = widget({ type = "textbox" })
local cpugraph  = awful.widget.graph()
-- Graph properties
cpugraph:set_width(50)
cpugraph:set_height(14)
cpugraph:set_max_value(100)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_color(beautiful.fg_end_widget)
cpugraph:set_gradient_angle(0)
cpugraph:set_gradient_colors({ beautiful.fg_end_widget,
    beautiful.fg_center_widget, beautiful.fg_widget })
-- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,     "$1")
vicious.register(tzswidget, vicious.widgets.thermal, "$1°C", 19, "TZS0")
-- }}}

-- {{{ Battery state
local baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.widget_bat)
-- Initialize widget
batwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- }}}

-- {{{ Memory usage
local memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
local membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_width(8)
membar:set_height(10)
membar:set_vertical(true)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_border_color(nil)
membar:set_color(beautiful.fg_widget)
membar:set_gradient_colors({ beautiful.fg_widget,
    beautiful.fg_center_widget, beautiful.fg_end_widget })
awful.widget.layout.margins[membar.widget] = { top = 2, bottom = 2 }
-- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ File system usage
local fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widgets
local fs = {
  r = awful.widget.progressbar(),  h = awful.widget.progressbar(),
  s = awful.widget.progressbar(),  b = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_width(5)
  w:set_height(12)
  w:set_vertical(true)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_border_color(beautiful.border_widget)
  w:set_color(beautiful.fg_widget)
  w:set_gradient_colors({ beautiful.fg_widget,
    beautiful.fg_center_widget, beautiful.fg_end_widget })
  awful.widget.layout.margins[w.widget] = { top = 1, bottom = 1 }
  -- Register buttons
  w.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec("rox", false) end)
  ))
end
-- Enable caching
vicious.enable_caching(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.r, vicious.widgets.fs, "${/ usep}",            599)
vicious.register(fs.h, vicious.widgets.fs, "${/home usep}",        599)
vicious.register(fs.s, vicious.widgets.fs, "${/mnt/storage usep}", 599)
vicious.register(fs.b, vicious.widgets.fs, "${/mnt/backup usep}",  599)
-- }}}

-- {{{ Network usage
local dnicon = widget({ type = "imagebox" })
local upicon = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
-- Initialize widgets
local netwidget = widget({ type = "textbox" })
local wetwidget = widget({ type = "textbox" })
-- Enable caching
vicious.enable_caching(vicious.widgets.net)
-- Register ethernet widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  .. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 3)
-- Register wireless widget
vicious.register(wetwidget, vicious.widgets.net, '<span color="'
  .. beautiful.fg_netdn_widget ..'">${wlan0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${wlan0 up_kb}</span>', 3)
-- }}}

-- {{{ Mail subject
local mailicon = widget({ type = "imagebox" })
mailicon.image = image(beautiful.widget_mail)
-- Initialize widget
local mailwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mailwidget, vicious.widgets.mbox, "$1", 181, "/home/anrxc/mail/Inbox")
-- Register buttons
mailwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec("urxvt -title Alpine -e alpine_exp") end)
))
-- }}}

-- {{{ Org-mode agenda
local orgicon = widget({ type = "imagebox" })
orgicon.image = image(beautiful.widget_org)
-- Initialize widget
local orgwidget = widget({ type = "textbox" })
-- Configure widget
local orgmode = {
  files = {
    "/home/anrxc/.org/work.org",     "/home/anrxc/.org/index.org",
    "/home/anrxc/.org/personal.org", "/home/anrxc/.org/computers.org"
  },
  color = {
    past   = '<span color="'..beautiful.fg_urgent..'">',
    today  = '<span color="'..beautiful.fg_normal..'">',
    soon   = '<span color="'..beautiful.fg_widget..'">',
    future = '<span color="'..beautiful.fg_netup_widget..'">'
}}
-- Register widget
vicious.register(orgwidget, vicious.widgets.org,
  orgmode.color.past .. '$1</span>|' .. orgmode.color.today  .. '$2</span>|' ..
  orgmode.color.soon .. '$3</span>|' .. orgmode.color.future .. '$4</span>',
  601, orgmode.files)
-- Register buttons
orgwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec("emacsclient --eval '(org-agenda-list)'") end),
  awful.button({ }, 3, function () exec("emacsclient --eval '(make-remember-frame)'") end)
))
-- }}}

-- {{{ Volume level
local volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
local volwidget = widget({ type = "textbox" })
local volbar    = awful.widget.progressbar()
-- Progressbar properties
volbar:set_width(8)
volbar:set_height(10)
volbar:set_vertical(true)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_border_color(nil)
volbar:set_color(beautiful.fg_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
    beautiful.fg_center_widget, beautiful.fg_end_widget })
awful.widget.layout.margins[volbar.widget] = { top = 2, bottom = 2 }
-- Enable caching
vicious.enable_caching(vicious.widgets.volume)
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, "$1%", 2, "PCM")
vicious.register(volbar,    vicious.widgets.volume, "$1",  2, "PCM")
-- Register buttons
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("kmix") end),
   awful.button({ }, 2, function () exec("amixer -q sset Master toggle") end),
   awful.button({ }, 4, function () exec("amixer -q sset PCM 2dB+") end),
   awful.button({ }, 5, function () exec("amixer -q sset PCM 2dB-") end)
)) volwidget:buttons( volbar.widget:buttons() )
-- }}}

-- {{{ Date and time
local dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget = widget({ type = "textbox" })
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%b %d, %R", 61)
-- Register buttons
datewidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () exec("pylendar.py") end)
))
-- }}}

-- {{{ System tray
local systray = widget({ type = "systray" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
local wibox     = {}
local promptbox = {}
local layoutbox = {}
local taglist   = {}
taglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev
))

for s = 1, screen.count() do
    -- Create a promptbox
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))

    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
    -- Create the wibox
    wibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 14,
        bg = beautiful.bg_normal, position = "top"
    })
    -- Add widgets to the wibox
    wibox[s].widgets = {
        {   taglist[s],
            layoutbox[s],
            promptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        s == screen.count() and systray or nil,
        separator, datewidget, dateicon,
        separator, volwidget, spacer, volbar.widget, volicon,
        separator, spacer, orgwidget, orgicon,
        separator, mailwidget, mailicon,
        separator, upicon, wetwidget, dnicon,
        separator, upicon, netwidget, dnicon,
        separator, fs.b.widget, fs.s.widget, fs.h.widget, fs.r.widget, fsicon,
        separator, spacer, membar.widget, spacer, memicon,
        separator, spacer, batwidget, baticon,
        separator, cpugraph.widget, spacer, tzswidget, cpuicon,
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

-- Client bindings
local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}


-- {{{ Key bindings
--
-- {{{ Global keys
local globalkeys = awful.util.table.join(
    -- {{{ Applications
    awful.key({ modkey }, "e", function () exec("emacsclient -n -c") end),
    awful.key({ modkey }, "r", function () exec("rox", false) end),
    awful.key({ modkey }, "u", function () exec("utorrent") end),
    awful.key({ modkey }, "w", function () exec("firefox") end),
    awful.key({ altkey }, "F1",  function () exec("urxvt") end),
    awful.key({ altkey }, "#49", function () teardrop("urxvt", "bottom") end),
    awful.key({ modkey }, "F2",  function () teardrop("gmrun", nil, nil, nil, 0.08) end),
    awful.key({ modkey }, "a", function () exec("urxvt -title Alpine -e alpine_exp") end),
    awful.key({ modkey }, "g", function () sexec("GTK2_RC_FILES=~/.gtkrc-gajim gajim") end),
    awful.key({ modkey }, "q", function () exec("emacsclient --eval '(make-remember-frame)'") end),
    -- }}}

    -- {{{ Multimedia keys
    awful.key({}, "#160", function () exec("kscreenlocker --forcelock") end),
    awful.key({}, "#146", function () exec("khelpcenter") end),
    awful.key({}, "#121", function () exec("pvol.py -m") end),
    awful.key({}, "#122", function () exec("pvol.py -p -c -2") end),
    awful.key({}, "#123", function () exec("pvol.py -p -c 2") end),
    awful.key({}, "#232", function () exec("plight.py -s -a") end),
    awful.key({}, "#233", function () exec("plight.py -s -a") end),
    awful.key({}, "#244", function () exec("sudo /usr/sbin/pm-hibernate") end),
    awful.key({}, "#150", function () exec("sudo /usr/sbin/pm-suspend") end),
    awful.key({}, "#156", function () exec("emacsclient -n -c") end),
    awful.key({}, "#225", function () exec("pypres.py") end),
    awful.key({}, "#181", function () exec("xrefresh") end),
    awful.key({}, "#180", function () exec("firefox -browser") end),
    awful.key({}, "#163", function () exec("urxvt -title Alpine -e alpine") end),
    awful.key({}, "#157", function () exec("geeqie") end),
    awful.key({}, "Print",function () exec("ksnapshot") end),
    -- }}}

    -- {{{ Prompt menus
    awful.key({ altkey }, "F2", function ()
        awful.prompt.run({ prompt = "Run: " }, promptbox[mouse.screen].widget,
            function (...) promptbox[mouse.screen].text = exec(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ altkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, promptbox[mouse.screen].widget,
            function (words)
                local xmessage = "xmessage -timeout 10 -file -"
                sexec("crodict " .. words .. " | " .. xmessage)
            end)
    end),
    awful.key({ altkey }, "F4", function ()
        awful.prompt.run({ prompt = "Manual: " }, promptbox[mouse.screen].widget,
            function (page) exec("urxvt -e man " .. page) end)
    end),
    awful.key({ altkey }, "F5", function ()
        awful.prompt.run({ prompt = "Run Lua code: " }, promptbox[mouse.screen].widget,
        awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
    end),
    awful.key({ altkey }, "F10", function ()
        awful.prompt.run({ prompt = "Connect: " }, promptbox[mouse.screen].widget,
            function (host) exec("urxvt -e ssh " .. host) end)
    end),
    awful.key({ altkey }, "F11", function ()
        awful.prompt.run({ prompt = "Calculate: " }, promptbox[mouse.screen].widget,
            function (expr)
                local xmessage = "xmessage -timeout 10 -file -"
                sexec("echo '" .. expr .. ' = ' ..
                  awful.util.eval("return (" .. expr .. ")") .. "' | " .. xmessage)
            end)
    end),
    awful.key({ altkey }, "F12", function ()
        awful.prompt.run({ prompt = "Web search: " }, promptbox[mouse.screen].widget,
            function (command)
                exec("firefox 'http://yubnub.org/parser/parse?command="..command.."'")
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
    awful.key({ altkey }, "n",   awful.tag.viewnext),
    awful.key({ altkey }, "p",   awful.tag.viewprev),
    awful.key({ altkey }, "Tab", awful.tag.history.restore),
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
    awful.key({ modkey }, "p",      function () awful.screen.focus_relative(1) end),
    awful.key({ modkey }, "s",      function () scratchpad.toggle() end),
    awful.key({ altkey }, "Escape", awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab", function () awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "j",   function () awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "k",   function () awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#48", function () awful.client.focus.bydirection("down")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#34", function () awful.client.focus.bydirection("up")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#47", function () awful.client.focus.bydirection("left")
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#51", function () awful.client.focus.bydirection("right")
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
local clientkeys = awful.util.table.join(
    awful.key({ modkey }, "b", function ()
        wibox[mouse.screen].visible = not wibox[mouse.screen].visible
    end),
    awful.key({ modkey }, "c", function (c) c:kill() end),
    awful.key({ modkey }, "d", function (c) scratchpad.set(c, 0.60, 0.60, true) end),
    awful.key({ modkey }, "f", function (c) awful.titlebar.remove(c)
        c.fullscreen = not c.fullscreen; c.above = not c.fullscreen
    end),
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
    awful.key({ modkey, "Shift" }, "0", function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Shift" }, "o", function (c) c.ontop = not c.ontop end),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, { modkey = modkey }) end
    end),
    awful.key({ modkey, "Control" }, "r",     function (c) c:redraw() end),
    awful.key({ modkey, "Control" }, "space", function (c) awful.client.floating.toggle(c)
        if   awful.client.floating.get(c)
        then c.above = true; awful.titlebar.add(c); awful.placement.no_offscreen(c)
        else c.above = false; awful.titlebar.remove(c) end
    end),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Shift" }, "c", function (c) exec("kill -CONT "..c.pid) end),
    awful.key({ modkey, "Shift" }, "s", function (c) exec("kill -STOP "..c.pid) end)
)
-- }}}

-- {{{ Keyboard digits
local keynumber = 0
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
    { rule = { class = "Firefox", instance = "Navigator" },
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
    { rule = { instance = "firefox-bin" },
      properties = { floating = true } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Signal function to execute when a new client appears
client.add_signal("manage", function (c, startup)
    -- Add a titlebar to each floating client
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if not c.titlebar and c.class ~= "Xmessage" then
            awful.titlebar.add(c, { modkey = modkey })
        end
        -- Floating clients are always on top
        c.above = true
    end

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function (c)
        if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Client placement
    if not startup then
        awful.client.setslave(c)

        if  not c.size_hints.user_position
        and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    -- Honor size hints
    c.size_hints_honor = false
end)
-- }}}

-- {{{ Focus signal functions
client.add_signal("focus",   function (c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
-- }}}
-- }}}
