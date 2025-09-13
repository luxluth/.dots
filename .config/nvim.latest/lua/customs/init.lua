return {
  ElfViewer = require("customs.readelf_viewer"),
  UpdateScheme = function()
    local scheme =
      vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait().stdout
    if scheme ~= nil and scheme:sub(0, scheme:len() - 1) ~= "'prefer-dark'" then
      vim.cmd("colorscheme dawnfox")
    else
      vim.cmd("colorscheme kanagawa-dragon")
    end
  end,
}
