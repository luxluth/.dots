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

      qmlls = {
        cmd = { "qmlls", "-E" },
      },

      ["rust-analyzer"] = {
        procMacro = {
          ignored = {
            leptos_macro = {
              "component",
              "server",
            },
          },
        },
      },
    },
  },
}
