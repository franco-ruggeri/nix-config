return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- see modifications
	},
	cmd = "Neogit",
	keys = {
		{ "<Leader>gg", "<Cmd>Neogit<CR>", desc = "[g]it status" },
	},
	opts = {
		integrations = {
			telescope = false, -- use vim.select.ui() (=> telescope-ui-select)
		},
	},
}
