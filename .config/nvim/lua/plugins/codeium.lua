local utils = require("utils")

return {
	"Exafunction/codeium.nvim",
	enabled = utils.os.is_macos(),
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	event = "InsertEnter",
	build = ":Codeium Auth",
	opts = {
		api = {
			host = vim.env.CODEIUM_HOST,
		},
		enterprise_mode = true,
		enable_chat = true,
		enable_cmp_source = false,
		virtual_text = {
			enabled = true,
			key_bindings = {
				accept = "<M-l>",
			},
		},
	},
	keys = {
		{ "<leader>ac", "<cmd>Codeium Chat<cr>", desc = "[A]I code assistant [c]hat" },
	},
}
