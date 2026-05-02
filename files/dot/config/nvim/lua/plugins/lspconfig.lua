return {
	"neovim/nvim-lspconfig",
	-- WARNING: Don't use `lsp/<name>.lua`. lspconfig would have precedence when merging settings.
	-- To override lspconfig settings, use `vim.lsp.config()` here.
	config = function()
		vim.lsp.config("basedpyright", {
			settings = {
				basedpyright = {
					analysis = {
						typeCheckingMode = "off",
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
