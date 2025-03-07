return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required dependency
		"williamboman/mason.nvim", -- package manager for linters and formatters
	},
	config = function()
		-- Automatic registration in null-ls of each package installed with Mason
		require("mason-null-ls").setup({ handlers = {}, ensure_installed = {}, automatic_installation = false })
	end,
}
