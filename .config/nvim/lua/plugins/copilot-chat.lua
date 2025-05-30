return {
	"CopilotC-Nvim/CopilotChat.nvim",
	enabled = true,
	dependencies = {
		"zbirenbaum/copilot.lua", -- required
		"nvim-lua/plenary.nvim", -- required
	},
	build = "make tiktoken",
	opts = {},
	keys = {
		-- Commands
		{ "<leader>aa", "<Cmd>CopilotChatOpen<CR>", mode = { "n", "x" }, desc = "[A]I open" },
		{ "<leader>ar", "<Cmd>CopilotChatReset<CR>", mode = { "n", "x" }, desc = "[A]I [r]eset" },
		-- Predefined prompts
		{ "<leader>ape", "<Cmd>CopilotChatExplain<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [e]xplain" },
		{ "<leader>apr", "<Cmd>CopilotChatReview<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [r]eview" },
		{ "<leader>apf", "<Cmd>CopilotChatFix<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [f]ix" },
		{ "<leader>apo", "<Cmd>CopilotChatOptimize<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [o]ptimize" },
		{ "<leader>apd", "<Cmd>CopilotChatDocs<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [d]ocument" },
		{ "<leader>apt", "<Cmd>CopilotChatTests<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [t]est" },
		{ "<leader>apc", "<Cmd>CopilotChatCommit<CR>", mode = { "n", "x" }, desc = "[A]I [p]rompt [c]ommit" },
	},
}
