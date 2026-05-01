return {
	"stevearc/oil.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- for file icons
	},
	opts = {
		view_options = {
			show_hidden = true,
		},
		lsp_file_methods = {
			timeout_ms = 10000, -- 10 seconds, scanning large codebases can be slow
			autosave_changes = true,
		},
	},
	config = function(_, opts)
		require("oil").setup(opts)
		vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
	end,
}
