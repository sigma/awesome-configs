-- {{{ Header
--
-- Awesome configuration file, using awesome 3.3.3 on Arch GNU/Linux.
--   * Adrian C. <anrxc_at_sysphere_org>

-- Updated on: Aug 27, 04:27:20 CEST 2009
-- Screenshot: http://sysphere.org/gallery/snapshots

-- FAQ: 
--   1. Statusbar widgets created with Vicious:
--        - http://git.sysphere.org/vicious

--   2. Why is there no Menu or a Taskbar in your config?
--        Everything is done with the keyboard.

--   3. Why these colors? 
--        It's Zenburn. Awesome, Emacs, Urxvt, Alpine... all use these colors.
--          - http://slinky.imukuppi.org/zenburnpage/

--      3a. My .Xdefaults can be found here: 
--            - http://git.sysphere.org/dotfiles

--   4. Fonts used on my desktop: 
--        Terminus  : http://www.is-vn.bg/hamster
--        Profont   : http://www.tobias-jung.de/seekingprofont

-- This work is licensed under the Creative Commons Attribution-Share Alike License.
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- {{{ Libraries
require("awful")
require("beautiful")
-- User libraries
require("vicious")
require("teardrop")
-- }}}


-- {{{ Variable definitions
--
-- Zenburn theme
beautiful.init(awful.util.getdir("config") .. "/zenburn.lua")

-- Modifier keys
altkey = "Mod1"      -- Alt_L
modkey = "Mod4"      -- Super_L

-- Window titlebars
use_titlebar = false -- True for floaters (arrange hook)

-- Window management layouts
layouts = {
    awful.layout.suit.tile,            -- 1
    awful.layout.suit.tile.left,       -- 2
    awful.layout.suit.tile.bottom,     -- 3
    awful.layout.suit.tile.top,        -- 4
    awful.layout.suit.fair,            -- 5
    awful.layout.suit.fair.horizontal, -- 6
    awful.layout.suit.max,             -- 7
--  awful.layout.suit.max.fullscreen,  -- /
    awful.layout.suit.magnifier,       -- 8
    awful.layout.suit.floating         -- 9
}

-- Application specific behaviour
apprules = {
--    cls = class, ins = instance, name, scr = screen, tag, float
    { cls = "Gajim.py",          scr = 1,              tag = 5 },
    { cls = "Knode",             scr = 1,              tag = 8 },
    { cls = "Akregator",         scr = 1,              tag = 8 },
    { cls = "Amarok",            scr = 1,              tag = 9 },
    { cls = "Amarokapp",         scr = 1,              tag = 9 },
    { cls = "Gimp",              scr = 1,              tag = 9 },
    { name = "Alpine",           scr = 1,              tag = 4 },
    { ins = "uTorrent.exe",      scr = screen.count(), tag = 9 },
    { cls = "Emacs",             scr = screen.count(), tag = 2 },
    { cls = "Firefox",           scr = screen.count(), tag = 3 },
    { cls = "Firefox",           ins = "Download",     float = true },
    { cls = "Firefox",           ins = "Places",       float = true },
    { cls = "Firefox",           ins = "Greasemonkey", float = true },
    { cls = "Firefox",           ins = "Extension",    float = true },
    { cls = "Firefox",           ins = "Scrapbook",    float = true },
    { cls = "Emacs",             ins = "_Remember_",   float = true },
    { cls = "Xmag",              ins = "xmag",         float = true },
    { cls = "Xmessage",          ins = "xmessage",     float = true },
    { cls = "ROX-Filer",         float = true },
    { cls = "Ark",               float = true },
    { cls = "Kgpg",              float = true },
    { cls = "Kmix",              float = true },
    { cls = "Geeqie",            float = true },
    { cls = "Smplayer",          float = true },
    { cls = "xine",              float = true },
    { name = "VLC media player", float = true },
    { name = "pinentry-gtk-2",   float = true },
}
-- }}}


-- {{{ Tags
--
-- Define tags table
tags = {}
tags.settings = {
    { name = "term",  layout = layouts[2]  },
    { name = "emacs", layout = layouts[1]  },
    { name = "web",   layout = layouts[1]  },
    { name = "mail",  layout = layouts[7]  },
    { name = "im",    layout = layouts[1], mwfact = 0.13 },
    { name = "6",     layout = layouts[9]  },
    { name = "7",     layout = layouts[9]  },
    { name = "rss",   layout = layouts[8]  },
    { name = "media", layout = layouts[9]  }
}

-- Initialize tags
for s = 1, screen.count() do
    tags[s] = {}
    for i, v in ipairs(tags.settings) do
        tags[s][i] = tag(v.name)
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
    end
    tags[s][1].selected = true
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separators
myspacer         = widget({ type = "textbox", name = "myspacer", align = "right" })
myseparator      = widget({ type = "textbox", name = "myseparator", align = "right" })
myspacer.text    = " "
myseparator.text = "|"
-- }}}

-- {{{ CPU usage graph and temperature
-- Widget icon
mycpuicon        = widget({ type = "imagebox", name = "mycpuicon", align = "right" })
mycpuicon.image  = image(beautiful.widget_cpu)
-- Initialize widgets
mythermalwidget  = widget({ type = "textbox", name = "mythermalwidget", align = "right" })
mycpuwidget      = widget({ type = "graph", name = "mycpuwidget", align = "right" })
-- CPU graph properties
mycpuwidget.width        = 50
mycpuwidget.height       = 0.90
mycpuwidget.grow         = "left"
mycpuwidget.bg           = beautiful.fg_off_widget
mycpuwidget.border_color = beautiful.border_widget
mycpuwidget:plot_properties_set("cpu", {
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    vertical_gradient = false })
-- Register widgets
vicious.register(mycpuwidget, vicious.widgets.cpu, "$1", 2, "cpu")
vicious.register(mythermalwidget, vicious.widgets.thermal, "$1°C", 60, nil, "TZS0")
-- }}}

-- {{{ Battery percentage and state indicator
-- Widget icon
mybaticon       = widget({ type = "imagebox", name = "mybaticon", align = "right" })
mybaticon.image = image(beautiful.widget_bat)
-- Initialize widget
mybatwidget     = widget({ type = "textbox", name = "mybatwidget", align = "right" })
-- Register widget
vicious.register(mybatwidget, vicious.widgets.bat, "$1$2%", 60, nil, "BAT0")
-- }}}

-- {{{ Memory usage bar
-- Widget icon
mymemicon       = widget({ type = "imagebox", name = "mymemicon", align = "right" })
mymemicon.image = image(beautiful.widget_mem)
-- Initialize widget
mymemwidget     = widget({ type = "progressbar", name = "mymemwidget", align = "right" })
-- MEM progressbar properties
mymemwidget.width          = 10
mymemwidget.height         = 0.9
mymemwidget.gap            = 0
mymemwidget.border_padding = 1
mymemwidget.border_width   = 0
mymemwidget.ticks_count    = 4
mymemwidget.ticks_gap      = 1
mymemwidget.vertical       = true
mymemwidget:bar_properties_set("mem", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100 })
-- Register widget
vicious.register(mymemwidget, vicious.widgets.mem, "$1", 60, "mem")
-- }}}

-- {{{ File system usage bars
-- Widget icon
myfsicon       = widget({ type = "imagebox", name = "myfsicon", align = "right" })
myfsicon.image = image(beautiful.widget_fs)
-- Initialize widget
myfswidget     = widget({ type = "progressbar", name = "myfswidget", align = "right" })
-- FS progressbar properties
myfswidget.width          = 20
myfswidget.height         = 0.9
myfswidget.gap            = 1
myfswidget.border_padding = 1
myfswidget.border_width   = 0
myfswidget.ticks_count    = 4
myfswidget.ticks_gap      = 1
myfswidget.vertical       = true
myfswidget:bar_properties_set("rootfs", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100 })
myfswidget:bar_properties_set("homefs", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100 })
myfswidget:bar_properties_set("storagefs", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100 })
myfswidget:bar_properties_set("backupfs", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_center_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100 })
-- Register widgets
vicious.register(myfswidget, vicious.widgets.fs, "${/ usep}",            240, "rootfs")
vicious.register(myfswidget, vicious.widgets.fs, "${/home usep}",        240, "homefs")
vicious.register(myfswidget, vicious.widgets.fs, "${/mnt/storage usep}", 240, "storagefs")
vicious.register(myfswidget, vicious.widgets.fs, "${/mnt/backup usep}",  240, "backupfs")
-- Register buttons
myfswidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("rox", false) end)))
-- }}}

-- {{{ Network usage statistics
-- Widget icons
myneticon         = widget({ type = "imagebox", name = "myneticon", align = "right" })
myneticonup       = widget({ type = "imagebox", name = "myneticonup", align = "right" })
myneticon.image   = image(beautiful.widget_net)
myneticonup.image = image(beautiful.widget_netup)
-- Initialize widgets
mynetwidget       = widget({ type = "textbox", name = "mynetwidget", align = "right" })
mynetfiwidget     = widget({ type = "textbox", name = "mynetfiwidget", align = "right" })
-- Register ethernet widget
vicious.register(mynetwidget, vicious.widgets.net,
  '<span color="'.. beautiful.fg_netdn_widget ..'">${eth0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth0 up_kb}</span>', 2)
-- Register wireless widget
vicious.register(mynetfiwidget, vicious.widgets.net,
  '<span color="'.. beautiful.fg_netdn_widget ..'">${wlan0 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${wlan0 up_kb}</span>', 2)
-- }}}

-- {{{ Mail subject (latest e-mail)
-- Widget icon
mymailicon       = widget({ type = "imagebox", name = "mymailicon", align = "right" })
mymailicon.image = image(beautiful.widget_mail)
-- Initialize widget
mymboxwidget     = widget({ type = "textbox", name = "mymboxwidget", align = "right" })
-- Register widget
vicious.register(mymboxwidget, vicious.widgets.mbox, "$1", 60, nil, "/home/anrxc/mail/Inbox")
-- Register buttons
mymboxwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.util.spawn("urxvt -title Alpine -e alpine_exp", false) end)))
-- }}}

-- {{{ Agenda and Todo (Emacs org-mode)
-- Widget icon
myorgicon       = widget({ type = "imagebox", name = "myorgicon", align = "right" })
myorgicon.image = image(beautiful.widget_org)
-- Initialize widget
myorgwidget     = widget({ type = "textbox", name = "myorgwidget", align = "right" })
-- Configure widget
myorgmode = {}
myorgmode.files  = {  -- Agenda files to be included
    os.getenv("HOME") .. "/.org/work.org",     os.getenv("HOME") .. "/.org/index.org",
    os.getenv("HOME") .. "/.org/personal.org", os.getenv("HOME") .. "/.org/computers.org"
}
myorgmode.colors = {  -- Index: past, today, soon, future
    '<span color="'..beautiful.fg_urgent..'">', '<span color="'..beautiful.fg_normal..'">',
    '<span color="'..beautiful.fg_widget..'">', '<span color="'..beautiful.fg_netup_widget..'">'
}
-- Register widget
vicious.register(myorgwidget, vicious.widgets.org, 
     myorgmode.colors[1] .. '$1</span>|' .. myorgmode.colors[2] .. '$2</span>|' ..
     myorgmode.colors[3] .. '$3</span>|' .. myorgmode.colors[4] .. '$4</span>',
     240, nil, myorgmode.files)
-- Register buttons
myorgwidget:buttons(awful.util.table.join(
  awful.button({ }, 1, function ()
      awful.util.spawn("emacsclient --eval '(org-agenda-list)'", false)
  end),
  awful.button({ }, 3, function ()
      awful.util.spawn("emacsclient --eval '(make-remember-frame)'", false)
  end)))
-- }}}

-- {{{ Volume level, progressbar and changer
-- Widget icon
myvolicon       = widget({ type = "imagebox", name = "myvolicon", align = "right" })
myvolicon.image = image(beautiful.widget_vol)
-- Initialize widgets
myvolwidget     = widget({ type = "textbox", name = "myvolwidget", align = "right" })
myvolbarwidget  = widget({ type = "progressbar", name = "myvolbarwidget", align = "right" })
-- VOL progressbar properties
myvolbarwidget.width          = 10
myvolbarwidget.height         = 0.9
myvolbarwidget.gap            = 0
myvolbarwidget.border_padding = 1
myvolbarwidget.border_width   = 0
myvolbarwidget.ticks_count    = 4
myvolbarwidget.ticks_gap      = 1
myvolbarwidget.vertical       = true
myvolbarwidget:bar_properties_set("volume", {
    bg        = beautiful.bg_widget,
    fg        = beautiful.fg_widget,
    fg_center = beautiful.fg_widget,
    fg_end    = beautiful.fg_end_widget,
    fg_off    = beautiful.fg_off_widget,
    min_value = 0,
    max_value = 100 })
-- Register widgets
vicious.register(myvolwidget, vicious.widgets.volume, "$1%", 2, nil, "PCM")
vicious.register(myvolbarwidget, vicious.widgets.volume, "$1", 2, "volume", "PCM")
-- Register buttons
myvolbarwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("kmix", false) end),
    awful.button({ }, 2, function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q sset PCM 2dB+", false) end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q sset PCM 2dB-", false) end)))
-- Register buttons
myvolwidget:buttons( myvolbarwidget:buttons() )
-- }}}

-- {{{ Date, time and a calendar
-- Widget icon
mydateicon       = widget({ type = "imagebox", name = "mydateicon", align = "right" })
mydateicon.image = image(beautiful.widget_date)
-- Initialize widget
mydatewidget     = widget({ type = "textbox", name = "mydatewidget", align = "right" })
-- Register widget
vicious.register(mydatewidget, vicious.widgets.date, "%b %e, %R", 60)
-- Register buttons
mydatewidget:buttons(awful.util.table.join(
    -- PyLendar: http://sysphere.org/~anrxc/j/archives/2009/03/11/desktop_calendars
    awful.button({ }, 1, function () awful.util.spawn("pylendar.py", false) end)))
-- }}}

-- {{{ System tray
-- Initialize widget
mysystray = widget({ type = "systray", align = "right" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
mywibox     = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist   = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, function (tag) tag.selected = not tag.selected end),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev))

-- Add a wibox to each screen
for s = 1, screen.count() do
    -- Create a promptbox
    mypromptbox[s] = awful.widget.prompt({ align = "left" })
    -- Create an imagebox widget with icons indicating active layout
    mylayoutbox[s] = widget({ type = "imagebox", align = "left" })
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))

    -- Create the taglist
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
    -- Create the wibox
    mywibox[s] = wibox({ position="top", height="14", fg=beautiful.fg_normal, bg=beautiful.bg_normal })
    -- Add widgets to the wibox (order matters)
    mywibox[s].widgets = { mytaglist[s],
                           mylayoutbox[s],
                           mypromptbox[s],
                           mycpuicon, mythermalwidget, myspacer, mycpuwidget,
                           myseparator,
                           mybaticon, mybatwidget, myspacer,
                           myseparator,
                           mymemicon, myspacer, mymemwidget, myspacer,
                           myseparator,
                           myfsicon, myfswidget, myspacer,
                           myseparator,
                           myneticon, mynetwidget, myneticonup,
                           myseparator,
                           myneticon, mynetfiwidget, myneticonup,
                           myseparator,
                           mymailicon, myspacer, mymboxwidget, myspacer,
                           myseparator,
                           myorgicon, myorgwidget, myspacer,
                           myseparator,
                           myvolicon, myvolwidget, myspacer, myvolbarwidget, myspacer,
                           myseparator,
                           mydateicon, mydatewidget,
                           myseparator,
                           s == screen.count() and mysystray or nil
    }
    mywibox[s].screen = s
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function ()
        awful.prompt.run({ prompt = "Run: " }, mypromptbox[mouse.screen].widget,
            function (...) mypromptbox[mouse.screen].text = awful.util.spawn(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
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
    awful.key({ altkey }, "#49", function () teardrop.toggle("urxvt") end),
    awful.key({ modkey }, "F2",  function () teardrop.toggle("gmrun", 1, 0.08) end),
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
    -- pvol: http://sysphere.org/~anrxc/j/archives/2009/03/21/pvol_and_ossaudiodev
    awful.key({}, "#121", function () awful.util.spawn("pvol.py -m", false) end),
    awful.key({}, "#122", function () awful.util.spawn("pvol.py -p -c -2", false) end),
    awful.key({}, "#123", function () awful.util.spawn("pvol.py -p -c 2", false) end),
    -- plight: http://sysphere.org/~anrxc/j/archives/2009/05/13/plight_and_brightness
    awful.key({}, "#232", function () awful.util.spawn("plight.py -s -a", false) end),
    awful.key({}, "#233", function () awful.util.spawn("plight.py -s -a", false) end),
    awful.key({}, "#244", function () awful.util.spawn("sudo /usr/sbin/pm-hibernate", false) end),
    awful.key({}, "#150", function () awful.util.spawn("sudo /usr/sbin/pm-suspend", false) end),
    awful.key({}, "#156", function () awful.util.spawn("emacsclient -n -c", false) end),
    -- pypres: http://sysphere.org/~anrxc/j/archives/2009/07/23/python_presentation_manager
    awful.key({}, "#225", function () awful.util.spawn("pypres.py", false) end),
    awful.key({}, "#181", function () awful.util.spawn("xrefresh", false) end),
    awful.key({}, "#180", function () awful.util.spawn("firefox -browser", false) end),
    awful.key({}, "#163", function () awful.util.spawn("urxvt -title Alpine -e alpine", false) end),
    awful.key({}, "#157", function () awful.util.spawn("geeqie", false) end),
    awful.key({}, "Print",function () awful.util.spawn("ksnapshot", false) end),
    -- }}}

    -- {{{ Prompt menus
    --     - Run, Dictionary, Manual, Lua, SSH, Calculator and Web search
    awful.key({ altkey }, "F2", function ()
        awful.prompt.run({ prompt = "Run: " }, mypromptbox[mouse.screen].widget,
            function (...) mypromptbox[mouse.screen].text = awful.util.spawn(unpack(arg), false) end,
            awful.completion.shell, awful.util.getdir("cache") .. "/history")
    end),
    awful.key({ altkey }, "F3", function ()
        awful.prompt.run({ prompt = "Dictionary: " }, mypromptbox[mouse.screen].widget,
            function (words)
                local xmessage = "xmessage -timeout 10 -file -"
                awful.util.spawn_with_shell("crodict " .. words .. " | " .. xmessage, false)
            end)
    end),
    awful.key({ altkey }, "F4", function ()
        awful.prompt.run({ prompt = "Manual: " }, mypromptbox[mouse.screen].widget,
            function (page) awful.util.spawn("urxvt -e man " .. page, false) end,
            function(cmd, cur_pos, ncomp)
                local pages = {}
                local m = 'IFS=: && find $(manpath||echo "$MANPATH") -type f -printf "%f\n"| cut -d. -f1'
                local c, err = io.popen(m)
                if c then while true do
                    local manpage = c:read("*line")
                    if not manpage then break end
                    if manpage:find("^" .. cmd:sub(1, cur_pos)) then
                        table.insert(pages, manpage)
                    end
                  end
                  c:close()
                else io.stderr:write(err) end
                if #cmd == 0 then return cmd, cur_pos end
                if #pages == 0 then return end
                while ncomp > #pages do ncomp = ncomp - #pages end
                return pages[ncomp], cur_pos
            end)
    end),
    awful.key({ altkey }, "F5", function ()
        awful.prompt.run({ prompt = "Run Lua code: " }, mypromptbox[mouse.screen].widget,
        awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
    end),
    awful.key({ altkey }, "F10", function ()
        awful.prompt.run({ prompt = "Connect: " }, mypromptbox[mouse.screen].widget,
            function (host) awful.util.spawn("urxvt -e ssh " .. host, false) end)
    end),
    awful.key({ altkey }, "F11", function ()
        awful.prompt.run({ prompt = "Calculate: " }, mypromptbox[mouse.screen].widget,
            function (expr)
                local xmessage = "xmessage -timeout 10 -file -"
                awful.util.spawn_with_shell("echo '" .. expr .. ' = ' ..
                awful.util.eval("return (" .. expr .. ")") .. "' | " .. xmessage, false)
            end)
    end),
    awful.key({ altkey }, "F12", function ()
        awful.prompt.run({ prompt = "Web search: " }, mypromptbox[mouse.screen].widget,
            function (command)
                awful.util.spawn("firefox 'http://yubnub.org/parser/parse?command="..command.."'", false)
                if tags[mouse.screen][3] then awful.tag.viewonly(tags[mouse.screen][3]) end
            end)
    end),
    -- }}}

    -- {{{ Awesome controls
    awful.key({ modkey, "Shift" }, "q", awesome.quit),
    awful.key({ modkey, "Shift" }, "r", function ()
        mypromptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
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
    awful.key({ modkey }, "p", function () awful.screen.focus(1) end),
    awful.key({ modkey }, "s", function ()
        for k, c in pairs(client.get(mouse.screen)) do
            if c.minimized then -- Scratchpad replacement/imitation
                awful.client.movetotag(awful.tag.selected(mouse.screen), c)
                awful.client.floating.set(c, true)
                awful.placement.centered(c)
                c.minimized = false; c.sticky = true
                client.focus = c; c:raise()
            end
        end
    end),
    awful.key({ altkey }, "Tab", awful.client.urgent.jumpto),
    awful.key({ modkey }, "Tab", function () awful.client.focus.history.previous();
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "j",   function () awful.client.focus.byidx(1);
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "k",   function () awful.client.focus.byidx(-1);
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#48", function () awful.client.focus.bydirection("down");
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#34", function () awful.client.focus.bydirection("up");
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#47", function () awful.client.focus.bydirection("left");
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey }, "#51", function () awful.client.focus.bydirection("right");
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
    awful.key({ modkey }, "b", function () -- Hide the wibox
        if mywibox[mouse.screen].screen == nil then mywibox[mouse.screen].screen = mouse.screen
        else mywibox[mouse.screen].screen = nil end
    end),
    awful.key({ modkey }, "c", function (c) c:kill() end),
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end),
    awful.key({ modkey }, "o",     awful.client.movetoscreen),
    awful.key({ modkey }, "t",     awful.client.togglemarked),
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
    awful.key({ modkey, "Control" }, "r",      function (c) c:redraw() end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    -- Suspend/resume on focus changes could be auto. when running on bat power, if only suspending FF:
    awful.key({ modkey, "Shift" }, "c", function (c) awful.util.spawn("kill -CONT "..c.pid, false) end),
    awful.key({ modkey, "Shift" }, "s", function (c) awful.util.spawn("kill -STOP "..c.pid, false) end)
)
-- }}}

-- {{{ Bind keyboard digits
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- }}}

-- {{{ Tag controls
for i = 1, keynumber do
    globalkeys = awful.util.table.join( globalkeys,
        awful.key({ modkey }, i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    awful.tag.viewonly(tags[screen][i])
                end
            end),
        awful.key({ modkey, "Control" }, i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    tags[screen][i].selected = not tags[screen][i].selected
                end
            end),
        awful.key({ modkey, "Shift" }, i,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.movetotag(tags[client.focus.screen][i])
                end
            end),
        awful.key({ modkey, "Control", "Shift" }, i,
            function ()
                if client.focus and tags[client.focus.screen][i] then
                    awful.client.toggletag(tags[client.focus.screen][i])
                end
            end),
        awful.key({ modkey, "Shift" }, "F" .. i,
            function ()
                local screen = mouse.screen
                if tags[screen][i] then
                    for k, c in pairs(awful.client.getmarked()) do
                        awful.client.movetotag(tags[screen][i], c)
                    end
                end
            end))
end
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Hooks
--
-- {{{ Hook function to execute when focusing a client
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)
-- }}}

-- {{{ Hook function to execute when unfocusing a client
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)
-- }}}

-- {{{ Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)
-- }}}

-- {{{ Hook function to execute when unmarking a client
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)
-- }}}

-- {{{ Hook function to execute when the mouse enters a client
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus (but disabled for magnifier layout)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
    end
end)
-- }}}

-- {{{ Hook function to execute when a new client appears
awful.hooks.manage.register(function (c)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
        -- Additionaly make sure it is not maximized
        --   - common problem with apps like Firefox
        c.maximized_vertical   = false
        c.maximized_horizontal = false
    end

    -- Add a titlebar to each client if enabled globaly
    --   - check the arrange hook for finer controls
    if use_titlebar then
        awful.titlebar.add(c, { modkey = modkey })
        c.titlebar.border_width = beautiful.border_width
        c.titlebar.border_color = beautiful.border_focus
    end

    -- Set client mouse bindings
    c:buttons(awful.util.table.join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
        awful.button({ modkey }, 1, awful.mouse.client.move),
        awful.button({ modkey }, 3, awful.mouse.client.resize)
    ))

    -- New clients may not receive focus (unfocusable), so set the border anyway
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check application->screen/tag mappings and floating state
    local target_screen, target_tag, target_float

    for _, rule in pairs(apprules) do
        if (((rule.cls  == nil) or (c.class    and c.class    == rule.cls))
        and ((rule.ins  == nil) or (c.instance and c.instance == rule.ins))
        and ((rule.name == nil) or (c.name and string.find(c.name, rule.name, 1, true))))
        then
            target_screen = rule.scr
            target_tag    = rule.tag
            target_float  = rule.float
        end
    end

    -- Apply application->screen/tag mappings and floating state
    if target_float  then awful.client.floating.set(c, target_float) end
    if target_screen then
        c.screen = target_screen
        awful.client.movetotag(tags[target_screen][target_tag], c)
    end

    -- Focus after tag mapping
    client.focus = c

    -- Set client key bindings
    c:keys(clientkeys)

    -- Set new clients as slaves
    awful.client.setslave(c)

    -- New floating windows:
    --   - don't cover the wibox
    awful.placement.no_offscreen(c)
    --   - don't overlap until it's unavoidable
    --awful.placement.no_overlap(c)
    --   - are centered on the screen
    --awful.placement.centered(c, c.transient_for)

    -- Honoring of size hints
    --   - false will remove gaps between windows
    c.size_hints_honor = false
end)
-- }}}

-- {{{ Hook function to execute when arranging the screen
awful.hooks.arrange.register(function (screen)
    -- Update layout imagebox widget with an icon indicating active layout
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- If no window has focus or current one is a desktop or a dock:
    if not client.focus then
        --   - give focus to the latest client in history
        local c = awful.client.focus.history.get(screen, 0)
        --   - give focus the the client under the pointer
        --local c = awful.mouse.client_under_pointer()
        if c then client.focus = c end
    end

    -- Fine grained borders and floaters control
    local visible_clients = awful.client.visible(screen)

    if #visible_clients > 0 then
        for _, c in pairs(visible_clients) do
            -- Floating clients always have borders
            if awful.client.floating.get(c) or layout == "floating" then
                c.border_width = beautiful.border_width
                if not c.fullscreen then
                    -- Floating clients always have titlebars
                    if not c.titlebar and c.class ~= "Xmessage" then
                        awful.titlebar.add(c, { modkey = modkey })
                    end
                    -- Floating clients are always on top
                    c.above = true
                end
            -- Tiled clients don't have borders if only one client is visible
            --elseif (#visible_clients == 1) or (layout == "max") then
            --   - avoid flicker in max layout if floaters are on top
            elseif #visible_clients == 1 then
                visible_clients[1].border_width = 0
            else
                c.border_width = beautiful.border_width
            end
        end
    end
end)
-- }}}
-- }}}
