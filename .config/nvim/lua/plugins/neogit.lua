return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- see modifications
		"nvim-telescope/telescope.nvim", -- for better menu UI
	},
	cmd = "Neogit",
	keys = {
		{ "<leader>gs", "<Cmd>Neogit<CR>", desc = "[g]it [s]tatus" },
	},
	opts = {},
}
