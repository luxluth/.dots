return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    -- Prevent fzf-lua from trying to re-hook vim.ui.select if already set
    opts.ui_select = false
    return opts
  end,
}
