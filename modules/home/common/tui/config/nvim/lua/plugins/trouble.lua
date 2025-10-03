return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		focus = true, -- for consistency with built-in quickfix and other plugins
		auto_preview = false, -- preview is annoying when jumping between windows
		open_no_results = true, -- useful to open windows just for layout
	},
	config = function(_, opts)
		require("trouble").setup(opts)

		vim.keymap.set("n", "<Leader>xx", "<Cmd>Trouble diagnostics open<CR>", { desc = "diagnostics open" })
		vim.keymap.set("n", "]x", "<Cmd>Trouble diagnostics next jump=true<CR>", { desc = "Next diagnostic" })
		vim.keymap.set("n", "[x", "<Cmd>Trouble diagnostics prev jump=true<CR>", { desc = "Previous diagnostic" })

		vim.api.nvim_set_hl(0, "TroubleNormal", { link = "Normal" })
		vim.api.nvim_set_hl(0, "TroubleNormalNC", { link = "Normal" })
	end,
}
