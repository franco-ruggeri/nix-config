return {
	"ravitemer/mcphub.nvim",
	version = false, -- latest commit, see https://github.com/ravitemer/mcphub.nvim/issues/185
	cmd = { "MCPHub" },
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},
	build = "bundled_build.lua",
	opts = {
		use_bundled_binary = true,
	},
}
