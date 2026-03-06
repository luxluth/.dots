return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        c3_lsp = {
          cmd = { "c3lsp" },
        },
      },
    },
  },
}
