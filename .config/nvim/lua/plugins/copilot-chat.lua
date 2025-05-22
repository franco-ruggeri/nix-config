return {
	"CopilotC-Nvim/CopilotChat.nvim",
	enabled = true,
	dependencies = {
		"zbirenbaum/copilot.lua",
		"nvim-lua/plenary.nvim", -- required
	},
	build = "make tiktoken",
	opts = {},
	keys = {
		{ "<leader>a", "<Cmd>CopilotChatToggle<CR>", desc = "[A]I code assistant chat" },
	},
}
