return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "LspAttach" },
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics toggle" },
		{ "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", desc = "Diagnostics [n]ext" },
		{ "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", desc = "Diagnostics [p]revious" },
	},
	opts = {
		open_no_results = true, -- useful to open windows just for layout
	},
	config = function(_, opts)
		local trouble = require("trouble")
		trouble.setup(opts)

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP functions to Trouble",
			callback = function(args)
				-- To get the same behavior as the default gO, we need to open the window with focus.
				-- Trouble takes care of calling vim.lsp.buf.document_symbol().
				vim.keymap.set(
					"n",
					"gO",
					"<cmd>Trouble symbols open focus=true<CR>",
					{ buffer = args.buf, desc = "[g]oto [o]utline (document symbols)" }
				)
			end,
		})
	end,
}
