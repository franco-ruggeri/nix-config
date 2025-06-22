return {
	"stevearc/overseer.nvim",
	keys = {
		-- TODO: change keymaps
		-- TODO: make menu UI be a floating window, I think there's a standardized way, check LazyVim
		{ "<leader>to", "<Cmd>OverseerToggle<CR>", desc = "Toggle Overseer" },
		{ "<leader>tr", "<Cmd>OverseerRun<CR>", desc = "Run Template" },
	},
	opts = {},
}
