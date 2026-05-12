local VARS = require("confs.variables")

hl.bind("SUPER + T", hl.dsp.exec_cmd(VARS.terminal))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + C", hl.dsp.exec_cmd("qs ipc call cc toggle"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(VARS.fileManager))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + S", hl.dsp.exec_cmd(VARS.menu))
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("~/.bin/theme-switch.fish"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("XDG_CURRENT_DESKTOP=GNOME gnome-control-center"))
hl.bind("PRINT", hl.dsp.exec_cmd(VARS.scriptsDir .. "/scrsht.fish"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd(VARS.scriptsDir .. "/scrsht.fish edit"))

-- bind = $mainMod, left, movefocus, l
-- bind = $mainMod, right, movefocus, r
-- bind = $mainMod, up, movefocus, u
-- bind = $mainMod, down, movefocus, d

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

for i = 1, 10 do
	hl.bind("SUPER + code:" .. (i + 9), hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + code:" .. (i + 9), hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(VARS.scriptsDir .. "/voldb.fish up"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(VARS.scriptsDir .. "/voldb.fish down"))
hl.bind("XF86AudioMute       ", hl.dsp.exec_cmd(VARS.scriptsDir .. "/voldb.fish mute"))
hl.bind("XF86AudioMicMute    ", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- TODO: update this
-- bind = $mainMod+Ctrl, mouse:274, exec, hyprctl keyword cursor:zoom_factor 3.0
-- bindr = $mainMod+Ctrl, mouse:274, exec, hyprctl keyword cursor:zoom_factor 1.0
