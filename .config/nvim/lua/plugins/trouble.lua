local ui = require("utils.ui")

-- TODO: use edgy to manage layouts
-- TODO: add integration with telescope
return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim", -- for integration with todo comments
	},
	opts = {
		open_no_results = true, -- useful to open windows just for layout
		win = { size = ui.panel_size },
		modes = {
			todo = {
				-- Default is { "buf[0]", "filename", "pos", "message" }
				-- That is, the items in the current buffer are always on top.
				-- We don't want the order to change when jumping to another buffer.
				-- Otherwise, next/prev navigation with keymaps does not work.
				sort = { "filename", "pos", "message" },
			},
		},
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		local panels = {
			diagnostics = {
				name = "Diagnostics",
				position = "bottom",
				open = function()
					vim.cmd("Trouble diagnostics open")
					vim.keymap.set(
						"n",
						"<M-n>",
						"<Cmd>Trouble diagnostics next jump=true<CR>",
						{ desc = "[n]ext todo" }
					)
					vim.keymap.set(
						"n",
						"<M-p>",
						"<Cmd>Trouble diagnostics prev jump=true<CR>",
						{ desc = "[p]rev todo" }
					)
				end,
				close = function()
					vim.cmd("Trouble diagnostics close")
					vim.keymap.del("n", "<M-n>")
					vim.keymap.del("n", "<M-p>")
				end,
			},
			{
				name = "Todo",
				position = "bottom",
				open = function()
					vim.cmd("Trouble todo open")
					vim.keymap.set("n", "<M-n>", "<Cmd>Trouble todo next jump=true<CR>", { desc = "[n]ext todo" })
					vim.keymap.set("n", "<M-p>", "<Cmd>Trouble todo prev jump=true<CR>", { desc = "[p]rev todo" })
				end,
				close = function()
					vim.cmd("Trouble todo close")
					vim.keymap.del("n", "<M-n>")
					vim.keymap.del("n", "<M-p>")
				end,
			},
			symbols = {
				name = "Symbols",
				position = "right",
				open = function()
					vim.cmd("Trouble symbols open")
				end,
				close = function()
					vim.cmd("Trouble symbols close")
				end,
			},
		}

		for _, panel in pairs(panels) do
			ui.add(panel)
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP functions to Trouble",
			callback = function(args)
				-- To get the same behavior as the default gO, we need to open the window with focus.
				-- Trouble takes care of calling vim.lsp.buf.document_symbol().
				vim.keymap.set("n", "gO", function()
					ui.open(panels.symbols)
				end, { buffer = args.buf, desc = "[g]oto [o]utline (document symbols)" })
			end,
		})
	end,
}
