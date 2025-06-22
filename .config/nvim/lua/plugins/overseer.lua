return {
	"stevearc/overseer.nvim",
	keys = {
		-- TODO: make menu UI be a floating window, I think there's a standardized way, check LazyVim
		{ "<leader>wj", "<Cmd>OverseerToggle<CR>", desc = "[w]indow [j]obs" },
		{ "<leader>j", "<Cmd>OverseerRun<CR>", desc = "[j]ob run" },
	},
	opts = {},
}
