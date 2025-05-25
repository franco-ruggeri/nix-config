return {
	"folke/todo-comments.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},
	opts = {
		sign_priority = 1000, -- override signs from linters (e.g. pylint)
	},
}
