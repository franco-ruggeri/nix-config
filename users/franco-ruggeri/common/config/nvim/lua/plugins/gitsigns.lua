return {
	"lewis6991/gitsigns.nvim",
	config = function()
		local gitsigns = require("gitsigns")
		gitsigns.setup({})
		vim.keymap.set("n", "<Leader>gb", gitsigns.blame, { desc = "[g]it [b]lame" })
	end,
}
