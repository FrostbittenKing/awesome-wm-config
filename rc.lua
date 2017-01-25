-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
blingbling = require("blingbling")
vicious = require("vicious")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local helper_dir = os.getenv("HOME") .. "/.config/awesome/helpers/"
-- freedesktop support
require('freedesktop.utils')
freedesktop.utils.icon_theme = 'gnome' -- look inside /usr/share/icons/, default: nil (don't use icon theme)
require('freedesktop.menu')

menubar.cache_entries = false
menubar.app_folders = { "~/.apps/" }
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu

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
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}


-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.get_themes_dir() .. "default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
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
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
    awful.layout.suit.corner.nw,
        -- awful.layout.suit.corner.ne,
        -- awful.layout.suit.corner.sw,
        -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
   end
end
-- }}}

-- freedesktop menu
menu_items = freedesktop.menu.new()

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "reboot" , function () awful.spawn.with_shell("sudo reboot") end},
   { "shutdown", function () awful.spawn.with_shell("sudo shutdown -h now") end},
   { "quit", function() awesome.quit() end}
}

table.insert(menu_items, { "awesome", myawesomemenu, beautiful.awesome_icon})
table.insert(menu_items, { "open terminal", terminal, freedesktop.utils.lookup_icon({icon = 'terminal'})})
table.insert(menu_items, {"games"})

-- mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
--                                    { "open terminal", terminal },
--				    {"games"}
--                                  }
--                        })

mymainmenu = awful.menu({ items = menu_items})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
-- Create a systray
mysystray = wibox.widget.systray()

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                    )
local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                 if not c:isvisible() and c.first_tag then
						    c.first_tag:view_only()
						 end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- volwidget = widget({type = "textbox"})
volwidget = wibox.widget.textbox()
vicious.register(volwidget, vicious.widgets.volume, " $1%", 1, "Master -c0")

 volwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.spawn("amixer -c0 -q set Master toggle", false) end),
    awful.button({ }, 3, function () awful.spawn("xterm -e alsamixer -c0", true) end),
    awful.button({ }, 4, function () awful.spawn("amixer -c0 -q set Master 5%+", false) end),
    awful.button({ }, 5, function () awful.spawn("amixer -c0 -q set Master 5%-", false) end)
))

-- Initialize widget
cpuwidget = wibox.widget.textbox()
-- widget({ type = "textbox" })
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")
-- Initialize widget
memwidget=blingbling.line_graph.new()
memwidget:set_height(18)
memwidget:set_width(100)
memwidget:set_font_size(8)
memwidget:set_background_color("#00000090")
memwidget:set_show_text(true)
memwidget:set_label("Mem load: $percent %")
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, '$1', 2)

-- netwidget
netwidget = wibox.widget.textbox()
-- widget({ type = "textbox", name = "netwidget" })
 netwidget.text='NET:'
 --bind nestat popup on textbox 
-- blingbling.popups.netstat(netwidget,{ title_color = beautiful.notify_font_color_1, established_color= beautiful.notify_font_color_3, listen_color=beautiful.notify_font_color_2})
--
my_net=blingbling.net({interface = "eth0", show_text = true})
my_net:set_height(18)
--activate popup with ip informations on the net widget Blingbling Example 4.png
my_net:set_ippopup()
my_net:set_v_margin(3)
my_net:set_show_text(true)
-- Pacman Widget
pacwidget = wibox.widget.textbox()

pacwidget_t = awful.tooltip({ objects = { pacwidget},})

vicious.register(pacwidget, vicious.widgets.pkg,
                function(widget,args)
                    local io = { popen = io.popen }
                    local s = io.popen("pacman -Qu")
                    local str = ''

                    for line in s:lines() do
                        str = str .. line .. "\n"
                    end
                    pacwidget_t:set_text(str)
                    s:close()
                    return "UPDATES: " .. args[1]
                end, 1800, "Arch")

                --'1800' means check every 30 minutes



local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons) 
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = "25" })
    s.mywibox:setup {
          layout = wibox.layout.align.horizontal,
	  { -- Left widgets
	    layout = wibox.layout.fixed.horizontal,
	    mylauncher,
	    s.mytaglist,
	    s.mypromptbox,
	  },
          s.mytasklist, -- Middle widge
           { -- Right widgets
               layout = wibox.layout.fixed.horizontal,
               pacwidget,
               my_net,
               memwidget,
               volwidget,
               mykeyboardlayout,
               wibox.widget.systray(),
               mytextclock,
               s.mylayoutbox,
           },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- Monitor Setup

-- Get active outputs
local function outputs()
   local outputs = {}
   local xrandr = io.popen("xrandr -q")
   if xrandr then
      for line in xrandr:lines() do
       output = line:match("^([%w-]+) connected ")
        if output then
	    outputs[#outputs + 1] = output
	     end
      end
      xrandr:close()
   end

   return outputs
end

local function arrange(out)
   -- We need to enumerate all the way to combinate output. We assume
   -- we want only an horizontal layout.
   local choices  = {}
   local previous = { {} }
   for i = 1, #out do
      -- Find all permutation of length `i`: we take the permutation
      -- of length `i-1` and for each of them, we create new
      -- permutations by adding each output at the end of it if it is
      -- not already present.
      local new = {}
      for _, p in pairs(previous) do
       for _, o in pairs(out) do
           if not awful.util.table.hasitem(p, o) then
	          new[#new + 1] = awful.util.table.join(p, {o})
		      end
		       end
      end
      choices = awful.util.table.join(choices, new)
      previous = new
   end

   return choices
end

-- Build available choices
local function menu()
   local menu = {}
   local out = outputs()
   local choices = arrange(out)

   for _, choice in pairs(choices) do
      local cmd = "xrandr"
      -- Enabled outputs
      for i, o in pairs(choice) do
       cmd = cmd .. " --output " .. o .. " --auto"
        if i > 1 then
	    cmd = cmd .. " --right-of " .. choice[i-1]
	     end
      end
      -- Disabled outputs
      for _, o in pairs(out) do
       if not awful.util.table.hasitem(choice, o) then
           cmd = cmd .. " --output " .. o .. " --off"
	    end
      end

      local label = ""
      if #choice == 1 then
       label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
      else
       for i, o in pairs(choice) do
           if i > 1 then label = label .. " + " end
	       label = label .. '<span weight="bold">' .. o .. '</span>'
	        end
      end

      menu[#menu + 1] = { label,
      		     cmd,
                          "/usr/share/icons/Tango/32x32/devices/display.png"}
   end

   return menu
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
      	    timer = nil,
	    	  cid = nil }
local function xrandr()
   -- Stop any previous timer
   if state.timer then
      state.timer:stop()
      state.timer = nil
   end

   -- Build the list of choices
   if not state.iterator then
      state.iterator = awful.util.table.iterate(menu(),
				function() return true end)
   end

   -- Select one and display the appropriate notification
   local next  = state.iterator()
   local label, action, icon
   if not next then
      label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
      state.iterator = nil
   else
      label, action, icon = unpack(next)
   end
   state.cid = naughty.notify({ text = label,
   	       			icon = icon,
					timeout = 4,
							screen = mouse.screen, -- Important, not all screens may be visible
							       	 	       font = "Free Sans 18",
									       	      	    replaces_id = state.cid }).id

   -- Setup the timer
   state.timer = timer { timeout = 4 }
   state.timer:connect_signal("timeout",
		  function()
				     state.timer:stop()
						     state.timer = nil
						     		        state.iterator = nil
										       	      if action then
														awful.spawn(action, false)
																	       end
																	           end)
   state.timer:start()
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({},"XF86TouchpadToggle", function () awful.spawn.with_shell("synclient TouchpadOff=$(synclient -l | grep -c 'TouchpadOff.*=.*0')") end),
    awful.key({},"XF86KbdBrightnessDown", function () awful.spawn.with_shell("~/bin/kbd_backlight down") end),
    awful.key({},"XF86KbdBrightnessUp", function () awful.spawn.with_shell("~/bin/kbd_backlight up") end),
    awful.key({},"XF86Display",xrandr),
    awful.key({modkey, }, "Delete", function () awful.spawn.with_shell("xscreensaver-command -lock") end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
	{ description = "go back", group = "client"}),
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)
end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)
end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true)
end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true)
end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)
end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)
end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)
end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)
end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),


    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"})
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle
  ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
	{description = "minimize", group = "client" }),
     -- all minimized clients are restored
         awful.key({ modkey, "Shift"   }, "n",
	     function()
	       local tag = awful.tag.selected()
	       	     for i=1, #tag:clients() do
	       	     	 tag:clients()[i].minimized=false
	       		 --tag:clients()[i]:redraw()
			 naughty.notify({text="gaylord"})
	       end
	end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s in screen do
   keynumber = math.min(9, math.max(#s.tags, keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i+9,
                  function ()
                          local screen = awful.screen.focused()
                          local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end),
	-- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
		      local screen = awful.screen.focused()
		      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
		  {description = "toggle tag #" .. i, group = "tag"}),
	-- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
		      if client.focus then
		      	 local tag = client.focus.screen.tags[i]
                      	 if tag then
                            client.focus:move_to_tag(tag)
			 end
                      end
                  end,
		  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
		      if client.focus then
		      	 local tag = client.focus.screen.tags[i]
                      	 if tag then
                            client.focus:toggle_tag(tag)
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
		     raise = true,
                     keys = clientkeys,
		     buttons = clientbuttons,
		     screen = awful.screen.preferred,
		     placement = awful.placement.no_overlap+awful.placement.no_offscreen,		     -- don't start applications maximized
		     maximized_vertical = false,
		     maximized_horizontal = false,
                     buttons = clientbuttons } },
    { rule = { class = "bioshock.i386" },
      properties = { fullscreen = true,screen = 1, tag = "7" } },
    { rule = { class = "UE4-Linux-Test" },
      properties = { floating = true,fullscreen = true,screen = 1, tag = "6" } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "URxvt" },
      properties = { opacity = 0.95 , size_hints_honor = false } },
--     { rule = { class = "Firefox" }, properties = {opacity = 0.85}}, 
--       { rule = { class = "Amarok" }, properties = {opacity = 0.75 }},
     { rule = { class = "Pidgin"}, properties = {screen = 1, tag = "2"}},
     { rule = { }, properties = { }, callback = function(c)
      if awful.tag.getidx() == 2 then
       	 awful.client.setslave(c)
      end
      end }
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2"  } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
     end
end)
     
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c       
    end
end)

client.connect_signal("focus", function(c) 
    c.border_color = beautiful.border_focus
--    c.opacity = 1.0
end  
)
client.connect_signal("unfocus",function(c) 
    c.border_color = beautiful.border_normal
--    c.opacity = 0.8
end
)
-- }}}

-- necessary for nm-applet to work (permissions)
 awful.spawn.with_shell("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
-- set pidgin window master width
screen[1].tags[2].master_width_factor = 0.15
awful.spawn.with_shell(helper_dir .. "nasa_bg.sh")
awful.spawn.with_shell(helper_dir .. "autostart.sh")
