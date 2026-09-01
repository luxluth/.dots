local VARS = require("vars")

local p = pattern

-- add binding to a hook
p.on("@start", function()
	p.exec_cmd("awww-daemon & " .. VARS.scriptsDir .. "/bg.fish")
	p.exec_cmd("qs")
	p.exec_cmd("fcitx5 -d")

	p.exec_cmd(VARS.scriptsDir .. "/portal.fish")
	p.exec_cmd(VARS.scriptsDir .. "/nvim.fish")

	p.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	p.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	p.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	p.exec_cmd("gnome-keyring-daemon --start --components=pkcs11,secrets,ssh")

	p.exec_cmd("seekr --silent")
end)

-- Add or update something to the configuartion fragments
p.config({
	input = {
		kb_layout = "be",
		kb_variant = "oss",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		repeat_rate = 30,
		repeat_delay = 500,

		sensitivity = 0.2, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
			disable_while_typing = false,
		},
	},

	gestures = {
		workspace_swipe_invert = false,
		workspace_swipe_threshold = 300,
	},
})

-- we register a gesture
p.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Binding to actions
-- Actions are predefined configurable functions

p.bind("SUPER + M", p.actions.quit())

p.bind("SUPER + Q", p.actions.window.close())
p.bind("SUPER + F", p.actions.window.fullscreen())

p.bind("SUPER + ALT + Left", p.actions.workspace.focus({ previous = true }))
p.bind("SUPER + ALT + Right", p.actions.workspace.focus({ next = true }))

p.bind("SUPER + SHIFT + T", p.actions.exec_cmd("~/.bin/theme-switch.fish"))
p.bind("SUPER + T", p.actions.exec_cmd(VARS.terminal))
p.bind("SUPER + S", p.actions.exec_cmd(VARS.menu))
p.bind("SUPER + E", p.actions.exec_cmd(VARS.fileManager))
p.bind("SUPER + C", p.actions.exec_cmd("qs ipc call cc toggle"))
p.bind("SUPER + R", p.actions.reload_config())

p.bind("XF86AudioRaiseVolume", p.actions.exec_cmd(VARS.scriptsDir .. "/voldb.fish up"))
p.bind("XF86AudioLowerVolume", p.actions.exec_cmd(VARS.scriptsDir .. "/voldb.fish down"))
p.bind("XF86AudioMute       ", p.actions.exec_cmd(VARS.scriptsDir .. "/voldb.fish mute"))
p.bind("XF86AudioMicMute    ", p.actions.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

p.bind("XF86MonBrightnessUp", p.actions.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
p.bind(
	"XF86MonBrightnessDown",
	p.actions.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
	{ locked = true, repeating = true }
)

p.bind("XF86AudioNext", p.actions.exec_cmd("playerctl next"))
p.bind("XF86AudioPause", p.actions.exec_cmd("playerctl play-pause"))
p.bind("XF86AudioPlay", p.actions.exec_cmd("playerctl play-pause"))
p.bind("XF86AudioPrev", p.actions.exec_cmd("playerctl previous"))

for i = 1, 10 do
	p.bind("SUPER + code:" .. (i + 9), p.actions.workspace.focus({ workspace = i }))
	p.bind("SUPER + SHIFT + code:" .. (i + 9), p.actions.window.move({ workspace = i }))
end

-- Mouse bindings for window dragging and resizing (BTN_LEFT=272, BTN_MIDDLE=274)
p.bind("SUPER + mouse:272", p.actions.window.drag(), { mouse = true })
p.bind("SUPER + mouse:274", p.actions.window.resize(), { mouse = true })
