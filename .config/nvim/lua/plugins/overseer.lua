return {
	"stevearc/overseer.nvim",
	keys = {
		{ "<leader>taa", "<Cmd>OverseerOpen<CR>", desc = "[ta]sk list" },
		{ "<leader>tar", "<Cmd>OverseerRun<CR>", desc = "[ta]sk [r]un" },
	},
	opts = {
		templates = {
			"builtin",
			"cmake",
		},
		task_list = {
			-- If direction is "bottom", the task view gets open alongside the task list.
			--
			-- Unfortunately, the task view does not get a filetype, so edgy.nvim can't detect it.
			-- See https://github.com/stevearc/overseer.nvim/issues/427
			--
			-- For this reason, we do not want to open the task view.
			direction = "left",
		},
	},
}
