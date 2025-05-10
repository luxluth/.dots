return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				c3_lsp = {
					cmd = { "c3lsp" },
				},
			},
		},
	},
  { "mason-org/mason.nvim", version = "^1.0.0" },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
}
