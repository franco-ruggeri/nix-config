return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- required
		"nvim-tree/nvim-web-devicons", -- for icons in code blocks
	},
	ft = "markdown",
	opts = {
		completions = {
			blink = { enabled = true },
		},
	},
	config = function(_, opts)
		local render_markdown = require("render-markdown")

		render_markdown.setup(opts)
		render_markdown.disable() -- disable by default

		vim.keymap.set("n", "<leader>mr", "<Cmd>RenderMarkdown toggle<CR>", { desc = "[m]arkdown [r]ender toggle" })
	end,
}
