return {
	"neovim/nvim-lspconfig",
	-- Warning: Don't use `lsp/<name>.lua`. lspconfig would have precedence when merging settings.
	-- To override lspconfig settings, use `vim.lsp.config()` here.
	config = function()
		vim.lsp.config("pylsp", {
			settings = {
				pylsp = {
					-- For Python, standard formatters and linters are available with null-ls.
					-- So, disable diagnostics and formatting plugins to avoid conflicts with them.
					plugins = {
						pyflakes = { enabled = false },
						autopep8 = { enabled = false },
						mccabe = { enabled = false },
						pycodestyle = { enabled = false },
						yapf = { enabled = false },
					},
				},
			},
		})
	end,
}
