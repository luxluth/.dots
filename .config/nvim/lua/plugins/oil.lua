return {
  "https://forge.barrettruth.com/barrettruth/canola.nvim",
  config = function()
    require("oil").setup({
      columns = {
        "size",
        "permissions",
        "mtime",
        "icon",
      },
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
    })
  end,
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
