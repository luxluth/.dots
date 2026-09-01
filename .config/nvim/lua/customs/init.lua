return {
  ElfViewer = require("customs.readelf_viewer"),
  UpdateScheme = function()
    local scheme =
      vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait().stdout
    if scheme ~= nil and scheme:sub(0, scheme:len() - 1) ~= "'prefer-dark'" then
      vim.o.background = "light"
      vim.cmd("colorscheme alabaster")
      vim.notify("Light Theme", vim.log.levels.INFO, { title = "Background - " .. scheme })
    else
      vim.cmd("colorscheme kanagawa")
      vim.notify("Dark theme", vim.log.levels.INFO, { title = "Background - " .. scheme })
    end
  end,
}
