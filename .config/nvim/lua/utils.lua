local M = {}

M.is_location_list = function(window)
	window = window or vim.api.nvim_get_current_win()
	return vim.fn.getwininfo(window)[1].loclist == 1
end

return M
