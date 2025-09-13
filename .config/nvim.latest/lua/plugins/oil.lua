return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    columns = {
      "size",
      "permissions",
      "mtime",
      "icon",
    },
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = false,
  },
  -- Optional dependencies
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
