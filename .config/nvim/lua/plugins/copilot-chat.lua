return {
	"CopilotC-Nvim/CopilotChat.nvim",
	dependencies = {
		"zbirenbaum/copilot.lua",
		{
			"nvim-lua/plenary.nvim", -- for curl, log and async functions (see docs)
			branch = "master",
		},
	},
	build = "make tiktoken",
	opts = {},
	keys = { -- lazy load on first toggle + define keymap
		{ "<leader>ac", "<cmd>CopilotChatToggle<cr>", desc = "[A]I copilot [c]hat" },
	},
}
