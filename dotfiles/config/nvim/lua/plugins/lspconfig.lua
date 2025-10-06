return {
	"neovim/nvim-lspconfig",
	-- WARNING: Don't use `lsp/<name>.lua`. lspconfig would have precedence when merging settings.
	-- To override lspconfig settings, use `vim.lsp.config()` here.
	config = function()
		-- For Python, standard formatters and linters are available with null-ls.
		-- So, disable diagnostics and formatting plugins to avoid conflicts with them.
		vim.lsp.config("pylsp", {
			settings = {
				pylsp = {
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

		-- For shell scripts, support also zsh files.
		vim.lsp.config("bashls", {
			filetypes = { "sh", "zsh" },
		})
	end,
}
