return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for linters and formatters
		"nvimtools/none-ls.nvim",
		"nvim-lua/plenary.nvim", -- required
	},
	config = function()
		-- Automatic registration in null-ls of each package installed with Mason
		require("mason-null-ls").setup({ ensure_installed = {}, automatic_installation = false, handlers = {} })
	end,
}
