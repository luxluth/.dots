return {
  "neovim/nvim-lspconfig",

  opts = {
    servers = {
      mojo = {},
      ty = {},
      pyright = {
        enabled = false,
        mason = false,
      },
    },
  },
}
