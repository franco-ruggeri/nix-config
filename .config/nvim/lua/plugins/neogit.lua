return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- see modifications
		"nvim-telescope/telescope.nvim", -- for better menu UI
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>gg", "<Cmd>Neogit<CR>", desc = "[g]it status" },
	},
	opts = {},
}
