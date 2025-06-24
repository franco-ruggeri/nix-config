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
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		vim.keymap.set("n", "<leader>taR", function()
			-- Recipe from https://github.com/stevearc/overseer.nvim/blob/master/doc/recipes.md#restart-last-task
			local tasks = overseer.list_tasks({ recent_first = true })
			if vim.tbl_isempty(tasks) then
				vim.notify("No tasks found", vim.log.levels.WARN)
			else
				overseer.run_action(tasks[1], "restart")
			end
		end, { desc = "[ta]sk [r]un last" })
	end,
}
