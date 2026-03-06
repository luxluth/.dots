-- OPTIONS
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
opt.termguicolors = true
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.colorcolumn = "80"

opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.linebreak = false
opt.list = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.pumblend = 10
opt.pumheight = 10
opt.ruler = false
opt.scrolloff = 4
opt.shiftwidth = 4
opt.tabstop = 4
opt.signcolumn = "no"
opt.smartcase = true
opt.undofile = true
opt.undolevels = 10000
opt.virtualedit = "block"
opt.wrap = false

-- KEYMAPS
local map = vim.keymap

-- Move to window using the <ctrl> hjkl keys
map.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- Buffers
map.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map.set("n", "bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })


-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Global
map.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

vim.pack.add({
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
    { src = "https://github.com/echasnovski/mini.deps" },
})


-- Packages Configurations

-- colorscheme
vim.cmd("colorscheme gruvbox")
vim.cmd(":hi statusline guibg=NONE")
-- vim.cmd(":hi signcolumn guibg=NONE")

local path_package = vim.fn.stdpath('data') .. '/mini_site/'
require('mini.deps').setup({ path = { package = path_package } })

local add = MiniDeps.add

add({ source = "echasnovski/mini.pick" })
require "mini.pick".setup()
map.set("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Browse files" })
map.set("n", "<leader>h", "<cmd>Pick help<cr>", { desc = "Browse Help Glossary" })


add({ source = "echasnovski/mini.icons" })
require "mini.icons".setup()

add({ source = "echasnovski/mini.surround" })
require "mini.surround".setup()
add({ source = "echasnovski/mini.pairs" })
require "mini.pairs".setup({
    modes = { insert = true, command = true, terminal = false },
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    skip_ts = { "string" },
    skip_unbalanced = true,
})

add({ source = 'echasnovski/mini.ai' })
require("mini.ai").setup()

add({ source = "stevearc/oil.nvim" })
require "oil".setup({
    columns = {
        "size",
        "permissions",
        "mtime",
        "icon",
    },
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = false,
})
map.set("n", "<M-e>", "<cmd>Oil<cr>", { silent = true })


add({ source = "mbbill/undotree" })
map.set('n', '<leader><F5>', vim.cmd.UndotreeToggle, { desc = "Show Undotree" })

add({ source = "L3MON4D3/LuaSnip" })
require "luasnip".setup()

add("mason-org/mason.nvim")
add({
    source = "mason-org/mason-lspconfig.nvim",
    depends = { 'neovim/nvim-lspconfig' }
})

require "mason".setup()
require "mason-lspconfig".setup({
    ensure_installed = { "lua_ls", "rust_analyzer", "clangd" },
})

add({
    source = "saghen/blink.cmp",
    depends = { "rafamadriz/friendly-snippets" },
    checkout = "v1.6.0"
})

require "blink.cmp".setup({
    appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
    },
    keymap = {
        preset = 'enter',
    }
})

map.set({ "i", "n", "s" }, "<esc>", function()
    vim.cmd("noh")
    -- cmp.actions.snippet_stop()
    return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

local capabilities = vim.tbl_deep_extend("force",
    vim.lsp.protocol.make_client_capabilities(),
    require("blink.cmp").get_lsp_capabilities({}, false),
    {
        textDocument = {
            foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            },
        },
    }
)

vim.lsp.config('*', { capabilities = capabilities })


vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        -- Format on save if the server supports it
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition)
        vim.keymap.set("n", "K", vim.lsp.buf.hover)
        vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
    end
})

add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'master',
    monitor = 'main',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = { 'lua', 'vimdoc', 'c', 'rust' },
    highlight = {
        enable = true,
        disable = function(_lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
        end,

        additional_vim_regex_highlighting = false,
    },
})

add("ibhagwan/fzf-lua")
require "fzf-lua".setup()

local exculde_addons_ft = {
    "fzf",
    "help",
    "mason",
    "neo-tree",
    "notify",
    "toggleterm",
}

add("lukas-reineke/indent-blankline.nvim")
require "ibl".setup({
    indent = {
        char = "│",
        tab_char = "│",
    },
    scope = { show_start = false, show_end = false },
    exclude = {
        filetypes = exculde_addons_ft,
    },
})

add('echasnovski/mini.indentscope')
require "mini.indentscope".setup({
    symbol = "│",
    options = { try_as_border = true },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = exculde_addons_ft,
    callback = function()
        vim.b.miniindentscope_disable = true
    end,
})

add({
    source = "folke/noice.nvim",
    depends = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" }
})

add("smjonas/inc-rename.nvim")
require "inc_rename".setup()

vim.keymap.set("n", "<leader>cr", function()
    return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })

require("noice").setup({
    presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
    },
})

vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
end, {
    nargs = "+",
    complete = function(_, _, _)
        local plugins = vim.pack.get()
        local names = {}
        for _, p in ipairs(plugins) do
            table.insert(names, p.spec.name or p.spec.src:match("^.+/(.+)$"))
        end
        return names
    end,
})
