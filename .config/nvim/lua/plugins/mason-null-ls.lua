return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for linters and formatters
		"nvimtools/none-ls.nvim",
		"nvim-lua/plenary.nvim", -- required
	},
	config = function()
		local null_ls = require("null-ls")
		local mason_null_ls = require("mason-null-ls")
		mason_null_ls.setup({
			ensure_installed = {},
			automatic_installation = false,
			-- TODO: this is work in progress
			handlers = {
				function(source_name, methods)
					mason_null_ls.default_setup(source_name, methods)
				end,
				pylint = function(source_name, methods)
					null_ls.register(null_ls.builtins.diagnostics.pylint)
				end,
			},
		})
	end,
}
