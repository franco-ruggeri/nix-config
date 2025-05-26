local ui = require("utils.ui")

-- TODO: use edgy to manage layouts
return {
	"mbbill/undotree",
	init = function()
		vim.g.undotree_SplitWidth = ui.panel_size.width
		vim.g.undotree_DiffpanelHeight = ui.panel_size.height

		local panel = {
			name = "Undotree",
			position = "left",
			open = function()
				vim.cmd("UndotreeShow | UndotreeFocus")

				-- Other panels might mess up the width, so we ensure it is set correctly
				vim.api.nvim_win_set_width(0, ui.panel_size.width)
			end,
			close = function()
				vim.cmd("UndotreeHide")
			end,
		}

		ui.add(panel)
	end,
}
