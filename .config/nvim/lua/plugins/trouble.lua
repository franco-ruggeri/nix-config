-- TODO: add integration with telescope
return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim", -- for integration with todo comments
	},
	opts = {
		auto_preview = false, -- disable preview window, annoying when jumping between windows
		open_no_results = true, -- useful to open windows just for layout
		modes = {
			diagonstics = {
				win = { bo = { filetype = "trouble-diagnostics" } }, -- for filtering in edgy.nvim
			},
			todo = {
				-- Default is { "buf[0]", "filename", "pos", "message" }
				-- That is, the items in the current buffer are always on top.
				-- We don't want the order to change when jumping to another buffer.
				-- Otherwise, next/prev navigation with keymaps does not work.
				sort = { "filename", "pos", "message" },
				win = { bo = { filetype = "trouble-todo" } }, -- for filtering in edgy.nvim
			},
			-- Custom mode for LSP document symbols
			-- Based on defaults from https://github.com/folke/trouble.nvim/blob/85bedb7eb7fa331a2ccbecb9202d8abba64d37b3/lua/trouble/sources/lsp.lua#L51
			my_lsp_document_symbols = {
				desc = "document symbols (without title)",
				events = {
					"BufEnter",
					{ event = "TextChanged", main = true },
					{ event = "CursorMoved", main = true },
					{ event = "LspAttach", main = true },
				},
				source = "lsp.document_symbols",
				groups = {
					{ "filename", format = "{file_icon} {filename} {count}" },
				},
				sort = { "filename", "pos", "text" },
				format = "{kind_icon} {symbol.name} {text:Comment} {pos}",
				win = { bo = { filetype = "trouble-document-symbols" } }, -- for filtering in edgy.nvim
			},
		},
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		vim.keymap.set("n", "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics toggle" })
		vim.keymap.set("n", "<leader>t", "<Cmd>Trouble todo toggle<CR>", { desc = "[t]odo comments toggle" })
		vim.keymap.set("n", "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "[n]ext todo" })
		vim.keymap.set("n", "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "[p]rev todo" })

		-- By default, gO opens the document symbols in a location list and focus on it.
		-- We want to get the same behavior but using Trouble instead of the location list.
		-- Trouble takes care of calling vim.lsp.buf.document_symbol().
		-- So, we just need to bind the keymap to open the document symbols with focus.
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP functions to Trouble",
			callback = function(args)
				vim.keymap.set(
					"n",
					"gO",
					"<cmd>Trouble my_lsp_document_symbols open focus=true<CR>",
					{ buffer = args.buf, desc = "[g]oto [o]utline (document symbols)" }
				)
			end,
		})
	end,
}
