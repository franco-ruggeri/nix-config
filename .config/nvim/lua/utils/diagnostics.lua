local M = {}

M.refresh = function()
	local diagnostics = vim.diagnostic.get()

	-- Include source in the message
	for i = 1, #diagnostics do
		local d = diagnostics[i]
		if d.source then
			d.message = string.format("%s [%s]", d.message, d.source)
		end
	end

	-- Send diagnostics to quickfix list
	local quickfix_items = vim.diagnostic.toqflist(diagnostics)
	vim.fn.setqflist({}, "r", { items = quickfix_items, title = "Diagnostics" })
end

M.toggle = function()
	local info = vim.fn.getqflist({ title = 1, winid = 1 })
	local title = info.title
	local window_id = info.winid

	if title == "Diagnostics" and window_id ~= 0 then
		vim.cmd("cclose")
	else
		M.refresh()
		vim.cmd("copen")
	end
end

return M
