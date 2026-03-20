return {
	"folke/todo-comments.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"folke/trouble.nvim", -- for integration with trouble
		"ibhagwan/fzf-lua", -- for integration with fzf-lua
	},
	opts = {
		sign_priority = 1000, -- show sign above diagnostic ones
	},
	config = function(_, opts)
		require("todo-comments").setup(opts)

		vim.keymap.set("n", "<Leader>c", "<Cmd>Trouble todo open<CR>", { desc = "todo [c]omment list" })
		vim.keymap.set("n", "<Leader>fc", "<Cmd>TodoFzfLua<CR>", { desc = "[f]ind todo [c]omment" })
	end,
}
