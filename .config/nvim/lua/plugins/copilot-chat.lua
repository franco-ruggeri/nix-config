local utils = require("utils")

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	enabled = utils.os.is_linux(),
	dependencies = {
		"zbirenbaum/copilot.lua",
		{ "nvim-lua/plenary.nvim", branch = "master" }, -- required
	},
	build = "make tiktoken",
	opts = {},
	keys = {
		{ "<leader>ac", "<cmd>CopilotChatToggle<cr>", desc = "[A]I code assistant [c]hat" },
	},
}
