-- return {
--   "nvim-treesitter/nvim-treesitter",
--   opts = {
--     -- ensure_installed = { "c3" },
--     -- Add parser configurations
--     parser_install_info = {
--       c3 = {
--         install_info = {
--           url = "https://github.com/c3lang/tree-sitter-c3",
--           files = { "src/parser.c", "src/scanner.c" },
--           branch = "main",
--         },
--         sync_install = false, -- Set to true if you want to install synchronously
--         auto_install = true, -- Automatically install when opening a file
--         filetype = "c3", -- if filetype does not match the parser name
--       },
--     },
--     highlight = {
--       enable = true,
--       additional_vim_regex_highlighting = false,
--     },
--   },
-- }

return {
  {
    "nvim-treesitter/nvim-treesitter",
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.c3 = {
        install_info = {
          url = "https://github.com/c3lang/tree-sitter-c3",
          files = { "src/parser.c", "src/scanner.c" },
          branch = "main",
        },
        sync_install = false, -- Set to true if you want to install synchronously
        auto_install = true, -- Automatically install when opening a file
        filetype = "c3", -- if filetype does not match the parser name
      }
    end,
  },
}
