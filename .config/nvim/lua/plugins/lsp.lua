return {
  "neovim/nvim-lspconfig",

  opts = {
    servers = {
      zls = {
        cmd = { "/home/luxluth/.bin/zls/zig-out/bin/zls" },
        filetypes = { "zig" },
        root_markers = { "build.zig" },
      },
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
