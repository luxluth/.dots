-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

local scheme =
  vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait().stdout
if scheme:sub(0, scheme:len() - 1) ~= "'prefer-dark'" then
  vim.cmd("colorscheme dawnfox")
else
  vim.cmd("colorscheme gruvbox")
end
