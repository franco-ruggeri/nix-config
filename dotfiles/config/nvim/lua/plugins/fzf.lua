return {
	"ibhagwan/fzf-lua",
	version = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()

		vim.keymap.set("n", "<Leader>ff", fzf.files, { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<Leader>fs", fzf.live_grep, { desc = "[f]ind [s]tring" })
		vim.keymap.set("n", "<Leader>fr", fzf.registers, { desc = "[f]ind [r]egister" })
	end,
}
