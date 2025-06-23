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
			left = { size = 50 },
			right = { size = 50 },
			bottom = { size = 15 },
		},
		animate = {
			enabled = false,
		},
		bottom = {
			{
				title = "Diagnostics",
				ft = "trouble-diagnostics",
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
				ft = "trouble-todo",
			},
		},
		left = {
			{
				title = "Document Symbols",
				ft = "trouble-document-symbols",
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
	},
}
