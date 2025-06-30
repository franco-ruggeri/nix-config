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

		vim.lsp.config("texlab", {
			settings = {
				texlab = {
					build = {
						-- texlab supports compiling the project in two ways:
						-- * With a custom LSP method.
						-- * With the onSave option.
						--
						-- Neovim's built-in LSP client does not support the custom LSP method for building.
						-- So, we use the onSave option. The project is compiled on save.
						onSave = true,
					},
				},
			},
		})
	end,
}
