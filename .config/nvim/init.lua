-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
local customs = require("customs")
customs.ElfViewer.setup()

function UpdateScheme()
  local scheme =
    vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait().stdout
  if scheme ~= nil and scheme:sub(0, scheme:len() - 1) ~= "'prefer-dark'" then
    vim.cmd("colorscheme dawnfox")
  else
    vim.cmd("colorscheme gruvbox")
  end
end

UpdateScheme()
