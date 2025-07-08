local utils = require("utils")

return {
	"folke/edgy.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.laststatus = 3
		vim.opt.splitkeep = "screen"
	end,
	opts = {
		options = {
			bottom = { size = 15 },
			left = { size = 0.2 },
			right = { size = 0.3 },
		},
		animate = {
			enabled = false,
		},
		bottom = {
			{
				title = "Diagnostics",
				ft = "trouble",
				filter = function(_, window)
					return vim.w[window].trouble.mode == "diagnostics"
				end,
			},
			{
				title = "QuickFix List",
				ft = "qf",
				filter = function(_, window)
					return not utils.is_location_list(window)
				end,
			},
			{
				title = "Todo Comments",
				ft = "trouble",
				filter = function(_, window)
					return vim.w[window].trouble.mode == "todo"
				end,
			},
		},
		left = {
			{
				title = "Explorer",
				ft = "neo-tree",
			},
			{
				title = "Outline",
				ft = "aerial",
			},
			{
				title = "Location List",
				ft = "qf",
				filter = function(_, window)
					return utils.is_location_list(window)
				end,
				wo = {
					wrap = false,
				},
			},
			{
				title = "Tasks",
				ft = "OverseerList",
			},
			{
				title = "Tests",
				ft = "neotest-summary",
			},
			{ ft = "undotree" },
			{ ft = "diff" },
		},
		right = {
			{
				title = "AI Assistant",
				ft = "codecompanion",
			},
		},
	},
}
