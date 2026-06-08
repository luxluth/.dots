local home = os.getenv("HOME")

return {
	terminal = home .. "/.local/bin/ghostty",
	fileManager = "nautilus",
	menu = "seekr",
	scriptsDir = home .. "/.config/hypr/scripts",
}
