return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen" },
	keys = {
		{ "<leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "[g]it [d]iffview open" },
		{ "<leader>gD", "<Cmd>DiffviewClose<CR>", desc = "[g]it [d]iffview close" },
	},
	opts = {},
}
