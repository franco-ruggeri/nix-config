return {
	"sindrets/diffview.nvim",
	config = function()
		require("diffview").setup({})
		vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "[g]it [d]iffview open" })
		vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "[g]it diff [c]lose" })
	end,
}
