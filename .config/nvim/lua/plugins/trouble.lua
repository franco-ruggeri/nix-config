return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim", -- for integration with todo comments
	},
	opts = {
		focus = true, -- for consistency with built-in quickfix and other plugins
		auto_preview = false, -- preview is annoying when jumping between windows
		open_no_results = true, -- useful to open windows just for layout
		modes = {
			diagnostics = {
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
			my_lsp_document_symbols = {
				-- From defaults: https://github.com/folke/trouble.nvim/blob/85bedb7eb7fa331a2ccbecb9202d8abba64d37b3/lua/trouble/sources/lsp.lua#L51
				-- ====================
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
				-- ====================
				-- Custom filter, based on https://github.com/folke/trouble.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
				filter = {
					any = {
						-- For help and markdown, keep all symbol kinds
						ft = { "help", "markdown" },
						-- For other file types, keep this set of symbol kinds
						kind = {
							"Class",
							"Constructor",
							"Enum",
							"Field",
							"Function",
							"Interface",
							"Method",
							"Module",
							"Namespace",
							"Package",
							"Property",
							"Struct",
							"Trait",
						},
					},
				},
				desc = "document symbols (without title)",
				win = { bo = { filetype = "trouble-document-symbols" } }, -- for filtering in edgy.nvim
			},
		},
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		vim.keymap.set("n", "<leader>xx", "<Cmd>Trouble diagnostics open<CR>", { desc = "Diagnostics" })
		vim.keymap.set("n", "<leader>t", "<Cmd>Trouble todo open<CR>", { desc = "[t]odo comments" })
		vim.keymap.set("n", "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "[n]ext todo" })
		vim.keymap.set("n", "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "[p]rev todo" })

		-- By default, gO opens the document symbols in a location list and focus on it.
		-- We want to get the same behavior but using Trouble instead of the location list.
		-- Trouble takes care of calling vim.lsp.buf.document_symbol().
		-- So, we just need to bind the keymap to open the document symbols with focus.
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP methods to Trouble",
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
