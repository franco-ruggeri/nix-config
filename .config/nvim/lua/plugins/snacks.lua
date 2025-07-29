return {
	"folke/snacks.nvim",
	opts = {
		image = {
			enabled = function()
				return vim.fn.getenv("GHOSTTY_BIN_DIR")
					and (vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1)
			end,
			math = { enabled = false }, -- render-markdown takes care of it
		},
	},
}
