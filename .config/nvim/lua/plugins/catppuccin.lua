return {
	"catppuccin/nvim",
	priority = 1000,
	opts = {},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.cmd.colorscheme("catppuccin")
	end,
}
