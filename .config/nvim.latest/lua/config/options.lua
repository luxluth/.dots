-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "80"
vim.opt.smoothscroll = false
vim.opt.showmode = false
-- vim.opt.winborder = "rounded"

if vim.g.neovide then
  vim.o.guifont = "IosevkaTerm Nerd Font Mono:h12"
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_left = 10
end

vim.filetype.add({
  extension = {
    c3 = "c3",
    c3i = "c3",
    c3t = "c3",
  },
})

vim.filetype.add({ extension = { flm = "flame" } })
vim.treesitter.language.register("markdown", "flame")

-- Give the tags a delimiter-like look
vim.api.nvim_set_hl(0, "@flm.tag.open", { link = "Delimiter" })
vim.api.nvim_set_hl(0, "@flm.tag.close", { link = "Delimiter" })
-- Optional: color the tag name differently
vim.api.nvim_set_hl(0, "@flm.tag.name", { link = "Type" })
vim.api.nvim_set_hl(0, "@flm.tag.name.close", { link = "Type" })
