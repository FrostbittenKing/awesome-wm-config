local mywidgets = {}
local vicious = require("vicious")
local awful = require("awful")
function mywidgets.volwidget(volwidget)
   vicious.register(volwidget, vicious.widgets.volume, " $1%", 1, "Master -c0")
   volwidget:buttons(awful.util.table.join(
			awful.button({ }, 1, function () awful.spawn("amixer -c0 -q set Master toggle", false) end),
			awful.button({ }, 3, function () awful.spawn("xterm -e alsamixer -c0", true) end),
			awful.button({ }, 4, function () awful.spawn("amixer -c0 -q set Master 5%+", false) end),
			awful.button({ }, 5, function () awful.spawn("amixer -c0 -q set Master 5%-", false) end)
					  )
   )
end

function mywidgets.cpuwidget(cpuwidget)
   vicious.register(cpuwidget, vicious.widgets.cpu, "$1%")
end

function mywidgets.memwidget(memwidget)
   memwidget:set_height(18)
   memwidget:set_width(100)
   memwidget:set_font_size(8)
   memwidget:set_background_color("#00000090")
   memwidget:set_show_text(true)
   memwidget:set_label("Mem load: $percent %")
-- Register widget
   vicious.register(memwidget, vicious.widgets.mem, '$1', 2)
end
function mywidgets.netwidget(my_net)
   my_net:set_height(18)
   --activate popup with ip informations on the net widget Blingbling Example 4.png
   my_net:set_ippopup()
   my_net:set_v_margin(3)
   my_net:set_show_text(true)
end

function mywidgets.pacwidget( data )
   vicious.register(data.w, vicious.widgets.pkg,
                function(widget,args)
                    local io = { popen = io.popen }
                    local s = io.popen("pacman -Qu")
                    local str = ''

                    for line in s:lines() do
                        str = str .. line .. "\n"
                    end
                    data.t:set_text(str)
                    s:close()
                    return "UPDATES: " .. args[1]
                end, 1800, "Arch")

                --'1800' means check every 30 minutes

end
return mywidgets
