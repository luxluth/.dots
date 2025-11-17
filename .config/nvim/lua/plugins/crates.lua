return {
  "saecki/crates.nvim",
  tag = "stable",
  config = function()
    require("crates").setup({})
  end,
  event = { "BufRead Cargo.toml" },
}
