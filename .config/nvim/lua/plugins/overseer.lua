return {
	"stevearc/overseer.nvim",
	version = false, -- latest commit, for my fix: https://github.com/stevearc/overseer.nvim/commit/fe7b2f9ba263e150ab36474dfc810217b8cf7400
	keys = {
		{ "<Leader>taa", "<Cmd>OverseerOpen<CR>", desc = "[ta]sk list" },
		{ "<Leader>tar", "<Cmd>OverseerRun<CR>", desc = "[ta]sk [r]un" },
	},
	opts = {
		templates = {
			"builtin",
			"cmake",
			"mypy",
			"pylint",
			"latexmk",
		},
		task_list = {
			-- If direction is "bottom", the task view gets opened alongside the task list.
			-- We want to open the task list but not the task view.
			direction = "left",
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		overseer.add_template_hook({ name = "^make" }, function(task_definition, task_util)
			task_util.add_component(task_definition, { "on_output_quickfix", open = true })
		end)

		vim.keymap.set("n", "<Leader>taR", function()
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
