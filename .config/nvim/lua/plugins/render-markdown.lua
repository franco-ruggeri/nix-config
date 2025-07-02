-- Enable also for CodeCompanion chat
local filetypes = { "markdown", "codecompanion" }

return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter", -- required
		"nvim-tree/nvim-web-devicons", -- for icons in code blocks
	},
	ft = filetypes,
	opts = {
		file_types = filetypes,
		completions = {
			lsp = { enabled = true },
		},
		-- Less intrusive rendering
		-- ====================
		-- Heading: No icons and background color
		heading = { enabled = false },
		-- Code: no background color
		-- Note that nil would not override defaults
		code = {
			highlight = "",
			highlight_info = "",
			highlight_border = "",
			highlight_fallback = "",
			highlight_inline = "",
		},
		-- ====================
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		vim.keymap.set("n", "<leader>mr", "<Cmd>RenderMarkdown toggle<CR>", { desc = "[m]arkdown [r]ender toggle" })
	end,
}
