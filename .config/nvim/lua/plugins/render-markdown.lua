local filetypes = { "markdown", "codecompanion", "Avante" } -- enable for AI chats
local textwidth = 81

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
		heading = {
			width = "block",
			min_width = textwidth, -- stop rendering at colored column
			icons = {
				"█ ",
				"██ ",
				"███ ",
				"████ ",
				"█████ ",
				"██████ ",
			},
		},
		code = {
			border = "thick", -- no concealed lines => no scrolling between normal and insert modes
			width = "block",
			min_width = textwidth,
			position = "right",
		},
		dash = {
			width = textwidth,
		},
	},
	config = function(_, opts)
		require("render-markdown").setup(opts)
		vim.keymap.set("n", "<Leader>mr", "<Cmd>RenderMarkdown toggle<CR>", { desc = "[m]arkdown [r]ender toggle" })
	end,
}
