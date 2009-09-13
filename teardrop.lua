--------------------------------------------------------------------------
-- Drop-down applications manager for the awesome window manager
--------------------------------------------------------------------------
-- Author: Adrian C. <anrxc.sysphere.org>
-- Licensed under the WTFPL version 2
--   * http://sam.zoy.org/wtfpl/COPYING
--------------------------------------------------------------------------
-- To use this module add:
--     require("teardrop")
-- to the top of your rc.lua and call:
--     teardrop.toggle(prog, position, height, width, sticky, screen)
-- from a keybinding
--
-- Parameters:
--   prog     - Program to run, for example: "urxvt" or "gmrun"
--   position - Position, "bottom" to slide in from the bottom of the
--              screen, "center" when creating a scratchpad, by
--              default it drops down from the "top"
--   width    - Width, in absolute pixels when > 1 or a width percentage
--              when < 1, 0.9999 (100% of the screen) by default
--   height   - Height, in absolute pixels when > 1 or a height percentage
--              when < 1, 0.25 (25% of the screen) by default
--   sticky   - Sticky, if true, will make the client visible on all tags
--              (useful when creating a scratchpad), false by default
--   screen   - Screen (optional)
--------------------------------------------------------------------------

-- Grab environment
local pairs = pairs
local awful = require("awful")
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
}


-- Teardrop: Drop-down applications manager for the awesome window manager
module("teardrop")


-- Application visibility toggle
local dropdown = {}
--
-- Create a new window for the drop-down application when it doesn't
-- exist, or toggle between hidden and visible states when it does.
function toggle(prog, position, width, height, sticky, screen)
    local position = position or "top"
    local width    = width    or 0.9999
    local height   = height   or 0.25
    local sticky   = sticky   or false
    local screen   = screen   or capi.mouse.screen

    if not dropdown[prog] then
        -- Create table
        dropdown[prog] = {}

        -- Add unmanage signal for teardrop programs
        capi.client.add_signal("unmanage", function (c)
            for scr, cl in pairs(dropdown[prog]) do
                if cl == c then
                    dropdown[prog][scr] = nil
                end
            end
        end)
    end

    if not dropdown[prog][screen] then
        spawnw = function (c)
            -- Store client
            dropdown[prog][screen] = c

            -- Teardrop clients are floaters
            awful.client.floating.set(c, true)

            -- Client geometry and placement
            local screengeom = capi.screen[screen].workarea

            if width  < 1 then width  = screengeom.width * width   end
            if height < 1 then height = screengeom.height * height end

            if position == "bottom" then
                posx = screengeom.x
                posy = screengeom.height + screengeom.y - height
            elseif position == "center" then
                posx = screengeom.x + (screengeom.width - width) / 2
                posy = screengeom.y + (screengeom.height - height) / 2
            else --  Top of the screen by default
                posx = screengeom.x
                posy = screengeom.y - screengeom.y
            end

            -- Client properties
            c:geometry({
                x = posx,      y = posy,
                width = width, height = height
            })
            --  * skip tasklist and always on top
            c.ontop = true
            c.above = true
            c.skip_taskbar = true
            --  * no titlebar and optional sticky
            if sticky     then c.sticky = true end
            if c.titlebar then
                awful.titlebar.remove(c)
            end

            -- Focus and raise
            c:raise()
            capi.client.focus = c

            -- Remove manage signal
            capi.client.remove_signal("manage", spawnw)
        end

        -- Add manage signal
        capi.client.add_signal("manage", spawnw)

        -- Spawn program
        awful.util.spawn(prog, false)
    else
        -- Get client
        c = dropdown[prog][screen]

        -- Hide when switching the workspace
        if c:isvisible() == false then
            c.hidden = true
            -- Switch the client to the current workspace
            awful.client.movetotag(awful.tag.selected(screen), c)
        end

        -- Focus and raise if hidden
        if c.hidden then
            -- Make sure a scratchpad is centered
            if position == "center" then
                awful.placement.centered(c)
            end
            c.hidden = false
            c:raise()
            capi.client.focus = c
        else -- Hide and detach tags if not
            c.hidden = true
            local tags = c:tags()
            for i, v in pairs(tags) do
                tags[i] = nil
            end
            c:tags(tags)
        end
    end
end
