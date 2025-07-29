local function should_enable_image()
	return vim.fn.getenv("GHOSTTY_BIN_DIR") and (vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1)
end

return {
	"folke/snacks.nvim",
	opts = {
		image = {
			enabled = should_enable_image(),
			math = { enabled = false }, -- render-markdown takes care of it
		},
	},
}
