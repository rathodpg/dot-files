-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- To get expose effect like Mac OSX
require("revelation")
-- Adding widgets
require("vicious")
require("helpers")
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- AUTOSTART APPS
-- awful.util.spawn_with_shell("run_once /home/shadyabhi/.config/awesome/autostart.sh")
-- }}}
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
naughty.config.default_preset.width            = 300
--[[]
revelation.config.match.exact = function(c, rule)
   if c.class == "yourterminalclasshere" then return false
   else return awful.rules.match(c, rule)
end --]] --doesn't work

-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
networks = {'eth0', 'wlan0'}
local exec   = awful.util.spawn

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "Browsing", "Conversation", "Coding", "Virtualbox" }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart awesome", awesome.restart },
   { "quit awesome", awesome.quit },
   { "quit/restart PC", awful.util.getdir("config") .. "/scripts/shutdown.sh"}
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal },
                                    { "Firefox", "/usr/bin/firefox"},
                                    { "Xrandr on", awful.util.getdir("config") .. "/scripts/monitor.sh"},
                                    { "Nautilus", "/usr/bin/nautilus"}
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(awful.util.getdir("config") .. "/icons/arch.png"),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)

spacer = widget({ type = "textbox" })
spacer.width = 3

-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(awful.util.getdir("config") .. "/icons/vol.png")

-- Initialize widgets
volwidget = widget({ type = "textbox" })
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
-- Register buttons
volwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("gnome-alsamixer") end),
   awful.button({ }, 4, function () exec("amixer -q set Master 2dB+", false) vicious.force({volwidget}) end),
   awful.button({ }, 5, function () exec("amixer -q set Master 2dB-", false) vicious.force({volwidget}) end)
))
-- }}
-- Temperature & RPM
tempwidget = widget({ type = "textbox", name = "mywidget" })
tempwidget.text = ""
tempicon = widget({ type = "imagebox" })
tempicon.image = image(awful.util.getdir("config") .. "/icons/temp.png")
tempicon:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec(awful.util.getdir("config") .. "/scripts/showtemp.sh") end)

))

-- CPU Widget
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(awful.util.getdir("config") .. "/icons/cpu.png")
-- Initialize widget
cpuwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")
-- }}}

-- RAM Usage Widget
memicon =  widget({ type = "imagebox" })
memicon.image = image(awful.util.getdir("config") .. "/icons/mem.png")
-- Initialize widget
memwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1%", 13)
-- }}}

-- Network Widget
function print_net(name, down, up)
	return name .. ": " .. down .. 'kB/s ' .. up .. 'kB/s'
end
dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })

-- Initialize widget
netwidget_box = widget({ type = "textbox" })
netwidget_box.width=150
-- Register widget
vicious.register(netwidget_box, vicious.widgets.net,
	function (widget, args)
		for _,device in pairs(networks) do
			if tonumber(args["{".. device .." carrier}"]) > 0 then
				--dnicon.image = image(awful.util.getdir("config") .. "/icons/down.png")
				--upicon.image = image(awful.util.getdir("config") .. "/icons/up.png")
				return print_net(device, args["{"..device .." down_kb}"], args["{"..device.." up_kb}"])
			end
		end
	end, 1)

--netwidget = wibox.widget.base.make_widget(netwidget_box)
--netwidget.fit = function(_, w, h)
--  return 100, h
--end
-- }}}

-- {{{ Battery state

-- Initialize widget
batwidget = widget({ type = "textbox" })
baticon = widget({ type = "imagebox" })

-- Register widget
vicious.register(batwidget, vicious.widgets.bat,
	function (widget, args)
		if args[2] == 0 then return ""
		else
			baticon.image = image(awful.util.getdir("config") .. "/icons/bat.png")
			return "<span color='white'>".. args[2] .. "% | " .. args [3] .. "</span>"
		end
	end, 5, "BAT0"
)
batwidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec(awful.util.getdir("config") .. "/scripts/showbatt.sh") end)
))

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     --[[]
                     awful.button({ }, 3, function ()
                                             if instance then
                                                instance:hide()
                                                instance = nil
                                             else
                                                 instance = awful.menu.clients({ width=250 })
                                             end
                                          end),
                     --]]
                     
                     -- Added openbox like feature of Right-click to close the window
                     awful.button({ }, 3, function (c)
                                              c:kill()
                                          end),
                     -- }}
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                             return awful.widget.tasklist.label.currenttags(c, s)
                                         end, mytasklist.buttons)
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
                       layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        spacer, separator, volwidget, volicon,
        spacer, tempicon,
        spacer, separator, batwidget, spacer, baticon,
        spacer, separator, memwidget, memicon,
        spacer, separator, upicon, netwidget_box, dnicon, 
        spacer, separator, cpuwidget,spacer, cpuicon,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- USER DEFINED KEY BINDINGS 
    awful.key({ }, "XF86PowerOff", function() awful.util.spawn(awful.util.getdir("config") .. "/scripts/shutdown.sh") end),
	awful.key({ }, "XF86AudioMute", function() awful.util.spawn("amixer sset Master toggle") end),
    awful.key({ modkey, }, "b", function() awful.util.spawn("/usr/bin/nautilus") end),
    awful.key({ modkey, }, "t", function() awful.util.spawn("/usr/bin/thunderbird") end),
	--awful.key({ }, "XF86Sleep", function() awful.util.spawn(awful.util.getdir("config") .. "/scripts/sleep.sh") end),
    awful.key({ modkey, "Shift"   }, "s", function() awful.util.spawn("scrot -s") end), 
    awful.key({ modkey, "Shift", "Control"   }, "s", function() awful.util.spawn("scrot") end), 
    awful.key({ "Mod1" }, "Escape", function ()
         -- If you want to always position the menu on the same place set coordinates
               awful.menu.menu_keys.down = { "Down", "Alt_L" }
                    local cmenu = awful.menu.clients({width=245}, { keygrabber=true, coords={x=525, y=330} })
              end),
    awful.key({}, "XF86AudioNext", function() awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")
                                    end),
    awful.key({}, "XF86AudioPrev", function() awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Prev")
                                    end),
    awful.key({}, "XF86AudioPlay", function() awful.util.spawn("dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
                                    end),
	awful.key({}, "XF86AudioLowerVolume", function() awful.util.spawn("amixer -q set Master 2dB-") end),
	awful.key({}, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer -q set Master 2dB+") end),
	awful.key({ modkey, }, "l", function() awful.util.spawn(awful.util.getdir("config") .. "/scripts/lockscreen.sh") end),

    awful.key({modkey}, "d", function() awful.util.spawn("/home/shadyabhi/codes/godict/godict.py") end),

    awful.key({modkey}, "e", function()
        revelation({})
        end),
    -- }}}
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    -- Added keyboard shortcuts
    awful.key({ "Mod1"           }, "F2", function() awful.util.spawn("/usr/bin/dmenu_run", false) end),
    -- End of "I added" ones
    -- 
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Shift" }, "t", function (c)
         if   c.titlebar then awful.titlebar.remove(c)
         else awful.titlebar.add(c, { modkey = modkey }) end
                                        end),
    --awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
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
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
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
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- The systray is a bit complex. We need to configure it to display
-- the right colors. Here is a link with more background about this:
--  http://thread.gmane.org/gmane.comp.window-managers.awesome/9028
xprop = assert(io.popen("xprop -root _NET_SUPPORTING_WM_CHECK"))
wid = xprop:read():match("^_NET_SUPPORTING_WM_CHECK.WINDOW.: window id # (0x[%S]+)$")
xprop:close()
if wid then
   wid = tonumber(wid) + 1
   os.execute("xprop -id " .. wid .. " -format _NET_SYSTEM_TRAY_COLORS 32c " ..
          "-set _NET_SYSTEM_TRAY_COLORS " ..
          "65535,65535,65535,65535,8670,8670,65535,32385,0,8670,65535,8670")
end
require('autorun')
