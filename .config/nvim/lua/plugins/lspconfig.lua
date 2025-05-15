local utils = require("utils")

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"nvim-telescope/telescope.nvim", -- for LSP pickers (used in on_attach)
		"artemave/workspace-diagnostics.nvim",
	},
	config = function()
		vim.lsp.config("pylsp", {
			on_attach = utils.lsp.on_attach,
			settings = {
				pylsp = {
					plugins = {
						pycodestyle = { enabled = false },
						autopep8 = { enabled = false },
					},
				},
			},
		})
	end,
}
