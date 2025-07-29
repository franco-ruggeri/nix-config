return {
	"folke/todo-comments.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"folke/trouble.nvim", -- for integration with trouble
		"nvim-telescope/telescope.nvim", -- for integration with telescope
	},
	opts = {
		sign_priority = 1000, -- show sign above diagnostic ones
	},
	config = function(_, opts)
		require("todo-comments").setup(opts)

		vim.keymap.set("n", "<Leader>cc", "<Cmd>Trouble todo open<CR>", { desc = "todo [c]omment list" })
		vim.keymap.set("n", "<Leader>cf", "<Cmd>TodoTelescope<CR>", { desc = "todo [c]omment [f]ind" })
	end,
}
