return {
  "sschleemilch/slimline.nvim",
  -- opts = {
  --   style = "fg",
  --   bold = true,
  --   hl = {
  --     secondary = "Comment",
  --   },
  --   configs = {
  --     mode = {
  --       hl = {
  --         normal = "Type",
  --         visual = "Keyword",
  --         insert = "Function",
  --         replace = "Statement",
  --         command = "String",
  --         other = "Function",
  --       },
  --     },
  --     path = {
  --       hl = {
  --         primary = "Label",
  --       },
  --     },
  --     git = {
  --       hl = {
  --         primary = "Function",
  --       },
  --     },
  --     filetype_lsp = {
  --       hl = {
  --         primary = "String",
  --       },
  --     },
  --   },
  -- },
  opts = {
    style = "fg",
    components = {
      left = {
        "mode",
        "path",
        "git",
        "recording",
      },
      center = {},
      right = {
        "diagnostics",
        "filetype_lsp",
        "progress",
      },
    },
    configs = {
      recording = {
        icon = "RECORDING @",
        hl = {
          primary = "Special",
        },
      },
    },
  },
}
