return {
	"ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},
	build = "bundled_build.lua",
	opts = {
		use_bundled_binary = true,
	},
}
