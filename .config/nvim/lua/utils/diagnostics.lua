local M = {}

M.quickfix_title = "Diagnostics"

local function format_quickfix_list(info)
	-- Default format extended with source and symbol
	local format = "%s|%d col %d-%d %s| %s%s%s"

	local items = vim.fn.getqflist({ id = info.id, items = 0 }).items
	local items_str = {}
	for i = info.start_idx, info.end_idx do
		local item = items[i]
		local source = item.user_data.source
		local code = item.user_data.code
		local item_str = format:format(
			vim.fn.bufname(item.bufnr),
			item.lnum,
			item.col,
			item.end_col,
			item.type,
			item.text,
			source and (" [%s]"):format(source) or "",
			code and (" (%s)"):format(code) or ""
		)
		table.insert(items_str, item_str)
	end

	return items_str
end

M.refresh = function()
	local diagnostics = vim.diagnostic.get()
	local quickfix_items = vim.diagnostic.toqflist(diagnostics)
	local n_items = #diagnostics

	for i = 1, n_items do
		local d = diagnostics[i]
		quickfix_items[i].user_data = {
			source = d.source,
			code = d.code,
		}
	end

	vim.fn.setqflist({}, "r", {
		items = quickfix_items,
		title = M.quickfix_title,
		quickfixtextfunc = format_quickfix_list,
	})
end

M.toggle = function()
	local info = vim.fn.getqflist({ title = 1, winid = 1 })
	local title = info.title
	local window_id = info.winid

	if title == M.quickfix_title and window_id ~= 0 then
		vim.cmd("cclose")
	else
		M.refresh()
		vim.cmd("copen")
	end
end

return M
