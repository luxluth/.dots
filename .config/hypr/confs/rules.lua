hl.window_rule({
	name = "incrust-firefox",
	match = {
		class = "my-window",
		title = "Picture-in-Picture",
	},

	pin = true,
	float = true,
})

hl.window_rule({
	name = "seekr-display",
	match = { class = "dev.luxluth.seekr", title = "seekr" },

	pin = true,
	dim_around = true,
	border_size = 1,
	animation = "slide-in",
})

hl.window_rule({
	name = "auth-pine",
	match = {
		class = "^polkit-gnome-authentication-agent-1.*|^gcr-prompter.*|^(pinentry-)(.*)|org.kde.polkit(.*)",
	},

	dim_around = true,
	stay_focused = true,
})

hl.window_rule({
	name = "srcsht",
	match = { class = "com.gabm.satty" },
	float = true,
})

hl.window_rule({
	name = "fullscreen-ignore",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-dragging",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.layer_rule({
	name = "notif-style",
	match = { namespace = "notification" },
	animation = "slide-in",
})

hl.layer_rule({
	name = "seekr-menu",
	match = { namespace = "seekr" },
	animation = "snapExtreme",
	dim_around = true,
})

hl.layer_rule({
	name = "qs-cc",
	match = { namespace = "qs-cc" },
	animation = "snapExtreme",
})

hl.layer_rule({
	name = "qs-pop",
	match = { namespace = "qs-pop" },
	animation = "snapExtreme",

	dim_around = true,
})

hl.layer_rule({
	name = "qs",
	match = { namespace = "qs-osd|qs-notification|qs-bar|qs-cc" },
	animation = "snapExtreme",
	blur = true,
	ignore_alpha = 0.1,
})
