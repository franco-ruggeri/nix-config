-- TODO: refactor with object-oriented approach
local keymaps_set = false

local function open_diagnostics_panel()
	vim.cmd("Trouble todo close")
	vim.cmd("Trouble diagnostics open")
	vim.keymap.set("n", "<M-n>", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "[n]ext todo" })
	vim.keymap.set("n", "<M-p>", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "[p]rev todo" })
	keymaps_set = true
end

local function open_todo_panel()
	vim.cmd("Trouble diagnostics close")
	vim.cmd("Trouble todo open")
	vim.keymap.set("n", "<M-n>", "<Cmd>Trouble todo next jump=true<CR>", { desc = "[n]ext todo" })
	vim.keymap.set("n", "<M-p>", "<Cmd>Trouble todo prev jump=true<CR>", { desc = "[p]rev todo" })
	keymaps_set = true
end

local function open_symbols_panel()
	vim.cmd("Trouble symbols open")
end

local function close_panels()
	vim.cmd("Trouble diagnostics close")
	vim.cmd("Trouble todo close")
	vim.cmd("Trouble symbols close")
	if keymaps_set then
		vim.keymap.del("n", "<M-n>")
		vim.keymap.del("n", "<M-p>")
		keymaps_set = false
	end
end

-- TODO: add integration with telescope
return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim", -- for integration with todo comments
	},
	opts = {
		open_no_results = true, -- useful to open windows just for layout
		-- win = {
		-- 	size = { width = 50, height = 15 }, -- larger than defaults
		-- },
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

		-- Layout:
		-- * Bottom panel: diagnostics/todo (mutually exclusive)
		-- * Right panel: symbols
		vim.keymap.set("n", "<leader>pd", open_diagnostics_panel, { desc = "[p]anel [d]iagnostics" })
		vim.keymap.set("n", "<leader>pt", open_todo_panel, { desc = "[p]anel [t]odo" })
		vim.keymap.set("n", "<leader>ps", open_symbols_panel, { desc = "[p]anel [s]ymbols" })
		vim.keymap.set("n", "<leader>pr", close_panels, { desc = "[p]anel [r]eset" })

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
