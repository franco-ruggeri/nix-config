return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- required
		"nvim-tree/nvim-web-devicons", -- for icons in code blocks
	},
	ft = "markdown",
	opts = {
		completions = {
			-- TODO: migrate to blink for completion
			blink = { enabled = true },
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		vim.keymap.set("n", "<leader>m", "<Cmd>RenderMarkdown toggle<CR>", { desc = "[m]arkdown render toggle" })
	end,
}
