return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for linters and formatters
		"nvimtools/none-ls.nvim",
		"nvim-lua/plenary.nvim", -- required
	},
	config = function()
		local mason_null_ls = require("mason-null-ls")
		mason_null_ls.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {},
		})
	end,
}
