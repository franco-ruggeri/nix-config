return {
	"folke/snacks.nvim",
	opts = {
		image = {
			enabled = vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1,
			math = { enabled = false }, -- render-markdown takes care of it
		},
	},
}
