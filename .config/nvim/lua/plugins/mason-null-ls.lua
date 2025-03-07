return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"nvimtools/none-ls.nvim",
		"nvim-lua/plenary.nvim", -- required
		"williamboman/mason.nvim", -- package manager for linters and formatters
	},
	config = function()
		-- Automatic registration in null-ls of each package installed with Mason
		require("mason-null-ls").setup({ ensure_installed = {}, automatic_installation = false, handlers = {} })
	end,
}
