return {
	"ibhagwan/fzf-lua",
	version = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		"fzf-tmux",
		files = {
			previewer = false,
			fzf_opts = { ["--tmux"] = "center" },
		},
	},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()

		vim.keymap.set("n", "<Leader>ff", fzf.files, { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<Leader>fs", fzf.live_grep, { desc = "[f]ind [s]tring" })
		vim.keymap.set("n", "<Leader>fr", fzf.registers, { desc = "[f]ind [r]egister" })
	end,
}
