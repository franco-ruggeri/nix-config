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
		{ "<leader>a", "<Cmd>CopilotChatToggle<CR>", desc = "[A]I code assistant chat" },
	},
}
