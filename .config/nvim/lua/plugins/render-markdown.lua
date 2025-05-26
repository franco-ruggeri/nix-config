return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- required
		"nvim-tree/nvim-web-devicons", -- for icons in code blocks
	},
	cmd = "RenderMarkdown",
	keys = {
		{ "<leader>mr", "<Cmd>RenderMarkdown toggle<CR>", desc = "[m]arkdown [r]ender toggle" },
	},
	opts = {
		completions = {
			-- TODO: migrate to blink for completion
			blink = { enabled = true },
		},
	},
	config = function(_, opts)
		local render_markdown = require("render-markdown")
		render_markdown.setup(opts)
		render_markdown.disable() -- disable by default
	end,
}
