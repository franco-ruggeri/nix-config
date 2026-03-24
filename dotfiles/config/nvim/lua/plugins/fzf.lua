return {
	"ibhagwan/fzf-lua",
	version = false,
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		"fzf-tmux",
		files = {
			previewer = false,
			fzf_opts = {
				["--tmux"] = "center",
				["--keep-right"] = "",
			},
		},
	},
	config = function(_, opts)
		local fzf = require("fzf-lua")
		fzf.setup(opts)
		fzf.register_ui_select()

		vim.keymap.set("n", "<Leader>ff", fzf.files, { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<Leader>fs", fzf.live_grep, { desc = "[f]ind [s]tring" })
		vim.keymap.set("n", "<Leader>fr", fzf.registers, { desc = "[f]ind [r]egister" })

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP methods to Fzf",
			callback = function(args)
				vim.keymap.set("n", "grr", fzf.lsp_references, { buffer = args.buf, desc = "[g]oto [r]eference" })
				vim.keymap.set("n", "gd", fzf.lsp_definitions, { buffer = args.buf, desc = "[g]oto [d]efinition" })
				vim.keymap.set("n", "gD", fzf.lsp_declarations, { buffer = args.buf, desc = "[g]oto [d]eclaration" })
			end,
		})
	end,
}
