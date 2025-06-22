return {
	"stevearc/overseer.nvim",
	keys = {
		{ "<leader>t", "<Cmd>OverseerRun<CR>", desc = "[t]ask run" },
		{ "<leader>wt", "<Cmd>OverseerOpen<CR>", desc = "[w]indow [t]ask list" },
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
