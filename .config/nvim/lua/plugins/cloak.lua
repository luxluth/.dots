return {
  "laytan/cloak.nvim",
  opts = function()
    return {
      enabled = true,
      cloak_character = "*",
      highlight_group = "Comment",
      patterns = {
        {
          file_pattern = {
            ".env*",
            "wrangler.toml",
            ".dev.vars",
            "*.tfvars",
            "*.auto.tfvars",
          },
          cloak_pattern = { "=.+", "(=%s*).+" },
          replace = "%1",
        },
      },
    }
  end,
}
