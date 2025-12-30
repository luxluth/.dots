return {
  "vyfor/cord.nvim",
  build = ":Cord update",
  event = "VeryLazy",
  opts = {
    display = {
      theme = "classic",
      flavor = "accent",
    },
    editor = {
      client = "neovim",
    },
    assets = {
      fasm = {
        name = "assembler",
        icon = "assembly",
        tooltip = "flat assembler 1",
        type = "language",
      },

      ["Cargo.toml"] = {
        text = "Managing dependencies",
      },
    },
    plugins = {
      "cord.plugins.diagnostics",
    },
  },
}
