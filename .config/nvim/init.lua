-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
local customs = require("customs")
customs.ElfViewer.setup()
customs.UpdateScheme()

-- if vim.g.neovide then
-- Hack:h14:#e-subpixelantialias:#h-none
-- end
