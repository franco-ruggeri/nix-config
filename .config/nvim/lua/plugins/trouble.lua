return {
	"folke/trouble.nvim",
	opts = {},
	cmd = "Trouble",
	keys = {
		{
			"<leader>xx",
			"<cmd>Trouble diagnostics toggle focus=true<cr>",
			desc = "trouble - diagnostics (global)",
		},
		{
			"<leader>xb",
			"<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
			desc = "trouble - diagnostics [b]uffer",
		},
		{
			"<leader>xl",
			"<cmd>Trouble loclist toggle focus=true<cr>",
			desc = "trouble - [l]ocation list",
		},
		{
			"<leader>xq",
			"<cmd>Trouble qflist toggle focus=true<cr>",
			desc = "trouble - [q]uickfix list",
		},
	},
}
