return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "LspAttach",
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics toggle" },
		{ "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", desc = "Diagnostics [n]ext" },
		{ "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", desc = "Diagnostics [p]revious" },
	},
	opts = {},
	config = function(_, opts)
		require("trouble").setup(opts)

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP functions to Trouble windows",
			callback = function(args)
				vim.keymap.set(
					"n",
					"gO",
					"<cmd>Trouble symbols open focus=true<CR>",
					{ buffer = args.buf, desc = "vim.lsp.buf.document_symbol()" }
				)
			end,
		})
	end,
}
