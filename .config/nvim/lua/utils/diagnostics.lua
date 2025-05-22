local M = {}

M.toggle_window = function()
	local info = vim.fn.getqflist({ title = 1, winid = 1 })
	local title = info.title
	local window_id = info.winid

	if title == "Diagnostics" and window_id ~= 0 then
		vim.cmd("cclose")
	else
		vim.diagnostic.setqflist()
		vim.cmd("copen") -- open anyway, even if there are no diagnostics
	end
end

M.refresh_window = function()
	vim.diagnostic.setqflist({ open = false })
end

return M
