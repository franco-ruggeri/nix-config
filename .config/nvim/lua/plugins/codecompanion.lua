return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		{
			"nvim-lua/plenary.nvim", -- required
			version = false, -- latest commit, required
		},
		{
			"nvim-treesitter/nvim-treesitter", -- required
			opts = {
				ensure_installed = { "markdown", "markdown_inline" }, -- required
			},
		},
		"ravitemer/mcphub.nvim", -- MCP integration
		"MeanderingProgrammer/render-markdown.nvim", -- markdown rendering
	},
	opts = {
		extensions = {
			mcphub = {
				callback = "mcphub.extensions.codecompanion",
				opts = {
					make_vars = true,
					make_slash_commands = true,
					show_result_in_chat = true,
				},
			},
		},
	},
}
