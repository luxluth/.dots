hl.config({
	input = {
		kb_layout = "be",
		kb_variant = "oss",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		repeat_rate = 30,
		repeat_delay = 500,

		follow_mouse = 1,

		sensitivity = 0.2, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = true,
			disable_while_typing = false,
		},
	},

	gestures = {
		workspace_swipe_invert = true,
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.device({
	name = "wacom-one-by-wacom-m-pen",
	output = "current",
})
