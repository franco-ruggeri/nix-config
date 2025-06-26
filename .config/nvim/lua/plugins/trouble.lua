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
		},
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		vim.keymap.set("n", "<leader>xx", "<Cmd>Trouble diagnostics open<CR>", { desc = "diagnostics open" })
		vim.keymap.set("n", "<leader>tc", "<Cmd>Trouble todo open<CR>", { desc = "[t]odo [c]omments" })
		vim.keymap.set("n", "]x", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "Next diagnostic" })
		vim.keymap.set("n", "[x", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "Previous diagnostic" })
	end,
}
