return {
	"folke/todo-comments.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},
	opts = {
		sign_priority = 1000, -- show sign above diagnostic ones
		highlight = {
			keyword = "fg", -- no background color for the keyword
		},
	},
}
