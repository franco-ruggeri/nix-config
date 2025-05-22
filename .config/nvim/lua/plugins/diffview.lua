return {
	"sindrets/diffview.nvim",
	config = function()
		require("diffview").setup({})
		vim.keymap.set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { desc = "[g]it [d]iffview open" })
		vim.keymap.set("n", "<leader>gD", "<Cmd>DiffviewClose<CR>", { desc = "[g]it [d]iffview close" })
	end,
}
