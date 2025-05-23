return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = { "FileType", "BufWinEnter" },
	cmd = "Trouble",
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics toggle" },
		{ "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", desc = "Diagnostics [n]ext" },
		{ "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", desc = "Diagnostics [p]revious" },
	},
	opts = {
		open_no_results = true, -- good for layout
		modes = {
			symbols = {
				focus = true, -- same behavior as original `gO`
				win = { position = "left" }, -- good to have code more in the center
			},
		},
	},
	config = function(_, opts)
		local trouble = require("trouble")
		trouble.setup(opts)

		vim.api.nvim_create_autocmd("FileType", {
			desc = "Set Trouble document symbol keymap",
			callback = function(args)
				-- In help and man, gO opens the outline in a location list, so we don't want to set the keymap.
				if vim.tbl_contains({ "help", "man" }, args.match) then
					return
				end

				-- In the rest of the filetypes, gO either calls vim.lsp.buf.document_symbol() or does nothing.
				-- We set the keymap to open the Trouble document symbol list.
				--
				-- This way:
				-- - In buffers with LSP clients, we get the same behavior as in the default gO keymap.
				-- - In buffers without LSP clients, we can still open the window to have a consistent layout.
				vim.keymap.set(
					"n",
					"gO",
					"<cmd>Trouble symbols open<CR>",
					{ buffer = args.buf, desc = "[g]oto [o]utline (document symbols)" }
				)
			end,
		})
	end,
}
