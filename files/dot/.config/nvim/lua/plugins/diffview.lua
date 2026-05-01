return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen" },
	keys = {
		{ "<Leader>gd", "<Cmd>DiffviewOpen<CR>", desc = "[g]it [d]iffview open" },
		{ "<Leader>gD", "<Cmd>DiffviewClose<CR>", desc = "[g]it [d]iffview close" },
	},
	opts = {},
}
