local filetypes = { "markdown", "codecompanion", "Avante" } -- enable for AI chats

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
		heading = { enabled = false }, -- no background color for headings
		code = {
			highlight = false, -- no background color for code blocks
			highlight_border = false, -- no background color for code info line
		},
		-- ====================
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		vim.keymap.set("n", "<Leader>mr", "<Cmd>RenderMarkdown toggle<CR>", { desc = "[m]arkdown [r]ender toggle" })
	end,
}
