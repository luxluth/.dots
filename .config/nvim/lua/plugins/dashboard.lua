return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    dashboard = {
      pane_gap = 2, -- empty columns between vertical panes
      preset = {
        keys = {
          { icon = "", key = "f", desc = "ファイルの検索", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = "", key = "n", desc = "新規ファイル", action = ":ene | startinsert" },
          -- { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          -- {
          --   icon = " ",
          --   key = "c",
          --   desc = "Config",
          --   action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          -- },
          -- { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          -- { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = "", key = "q", desc = "終了する", action = ":qa" },
        },
        header = [[
ooooo   ooooo                                                                  
`888'   `888'                                                                  
 888     888   .oooo.   ooo. .oo.  .oo.   ooo. .oo.  .oo.    .ooooo.  oooo d8b 
 888ooooo888  `P  )88b  `888P"Y88bP"Y88b  `888P"Y88bP"Y88b  d88' `88b `888""8P 
 888     888   .oP"888   888   888   888   888   888   888  888ooo888  888     
 888     888  d8(  888   888   888   888   888   888   888  888    .o  888     
o888o   o888o `Y888""8o o888o o888o o888o o888o o888o o888o `Y8bod8P' d888b    
                                                                               
        ]],
      },

      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
      },
    },
  },
}
