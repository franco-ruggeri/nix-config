local function is_location_list(window)
	return vim.fn.getwininfo(window)[1].loclist == 1
end

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
				title = "Todo Comments",
				ft = "trouble-todo",
			},
			{
				title = "QuickFix",
				ft = "qf",
				filter = function(_, window)
					return not is_location_list(window)
				end,
			},
			{
				title = "Location List",
				ft = "qf",
				filter = function(_, window)
					return is_location_list(window)
				end,
			},
		},
		left = {
			{
				title = "Document Symbols",
				ft = "trouble-document-symbols",
			},
			{ ft = "undotree" },
			{ ft = "diff" },
		},
	},
}
