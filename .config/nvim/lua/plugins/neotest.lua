return {
	"nvim-neotest/neotest",
	dependencies = {
		-- Required
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Adapters
		"nvim-neotest/neotest-python",
	},
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("neotest").setup({
			adapters = {
				require("neotest-python"),
			},
		})
	end,
}
