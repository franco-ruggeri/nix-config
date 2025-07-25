return {
	"folke/snacks.nvim",
	lazy = true, -- load on demand (e.g., only in certain projects via .nvim.lua)
	opts = {
		image = {
			math = { enabled = false }, -- render-markdown takes care of it
		},
	},
}
