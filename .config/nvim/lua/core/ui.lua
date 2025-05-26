-- TODO: use edgy to manage layouts
local M = {}

---@class Panel
---@field name string Name of the panel, used in the keymap descriptions
---@field position string Position of the panel ("left", "right", "top", "bottom")
---@field open function() Function to open the panel
---@field close function() Function to close the panel

M.panel_size = {
	width = 50,
	height = 15,
}

M.panels = {
	left = {},
	right = {},
	bottom = {},
}

M.open = function(panel)
	for _, p in pairs(M.panels[panel.position]) do
		if p ~= panel then
			M.close(p)
		end
	end
	panel.open()
	panel.is_open = true
end

M.close = function(panel)
	if panel.is_open then
		panel.close()
		panel.is_open = false
	end
end

M.reset = function()
	for _, p_pos in pairs(M.panels) do
		for _, p in pairs(p_pos) do
			M.close(p)
		end
	end
end

M.add = function(panel)
	table.insert(M.panels[panel.position], panel)
	panel.is_open = false

	local key = panel.name:sub(1, 1)
	local description = ("[U]I [%s]%s"):format(key:lower(), panel.name:sub(2))

	vim.keymap.set("n", ("<leader>u%s"):format(key:lower()), function()
		M.open(panel)
	end, { desc = description .. " open" })
	vim.keymap.set("n", ("<leader>u%s"):format(key:upper()), function()
		M.close(panel)
	end, { desc = description .. " close" })
end

M.setup = function()
	vim.keymap.set("n", "<leader>ur", M.reset, { desc = "[U]I [r]eset" })
end

return M
