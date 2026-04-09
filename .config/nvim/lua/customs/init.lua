return {
  ElfViewer = require("customs.readelf_viewer"),
  UpdateScheme = function()
    local scheme =
      vim.system({ "gsettings", "get", "org.gnome.desktop.interface", "color-scheme" }, { text = true }):wait().stdout
    if scheme ~= nil and scheme:sub(0, scheme:len() - 1) ~= "'prefer-dark'" then
      vim.o.background = "light"
      vim.cmd("colorscheme alabaster")
      vim.notify("USING Alabaster", vim.log.levels.WARN, { title = "INIT" })
    else
      vim.cmd("colorscheme bamboo_muted")
      vim.notify("USING Bamboo", vim.log.levels.WARN, { title = "INIT" })
    end
  end,
}
