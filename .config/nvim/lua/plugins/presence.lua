return {
  "vyfor/cord.nvim",
  build = "./build || .\\build",
  event = "VeryLazy",
  opts = {
    main_image = "file",
    assets = {
      fasm = {
        name = "assembler",
        icon = "asm",
        tooltip = "flat assembler 1",
        type = "language",
      },
    },
  },
}
