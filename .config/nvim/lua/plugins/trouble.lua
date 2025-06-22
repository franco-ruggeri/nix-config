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
				win = { bo = { filetype = "trouble-diagnostics" } },
			},
			todo = {
				-- Default is { "buf[0]", "filename", "pos", "message" }
				-- That is, the items in the current buffer are always on top.
				-- We don't want the order to change when jumping to another buffer.
				-- Otherwise, next/prev navigation with keymaps does not work.
				sort = { "filename", "pos", "message" },
				win = { bo = { filetype = "trouble-todo" } },
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
					-- For lua, disable the package symbols, as language-server detects control flow structures as packages
					["not"] = {
						ft = "lua",
						kind = "Package",
					},
				},
				desc = "document symbols (without title)",
				win = { bo = { filetype = "trouble-document-symbols" } },
			},
		},
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		vim.keymap.set("n", "<leader>wx", "<Cmd>Trouble diagnostics open<CR>", { desc = "[w]indow diagnostics" })
		vim.keymap.set("n", "<leader>wc", "<Cmd>Trouble todo open<CR>", { desc = "[w]indow todo [c]omments" })
		vim.keymap.set("n", "]x", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "Next diagnostic" })
		vim.keymap.set("n", "[x", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "Previous diagnostic" })

		vim.api.nvim_create_autocmd("FileType", {
			desc = "Bind LSP methods to Trouble",
			callback = function(args)
				-- The default behavior of gO depends on the filetype:
				-- * For help and man buffers, gO opens the outline in a location list. We want to keep that behavior.
				-- * For buffers with LSP clients attached, gO opens the document symbols in a location list. We want to change that to open Trouble's document symbols.
				-- * For other filetypes, gO does nothing. We want to open Trouble's document symbols anyway, as it's nice to have it open for layout reasons.
				--
				-- Trouble takes care of calling vim.lsp.buf.document_symbol(). So, it's enough to open Trouble's document symbols.
				if not vim.tbl_contains({ "help", "man" }, args.match) then
					vim.keymap.set(
						"n",
						"gO",
						"<Cmd>Trouble my_lsp_document_symbols open<CR>",
						{ buffer = args.buf, desc = "[g]oto [o]utline (document symbols)" }
					)
				end
			end,
		})
	end,
}
