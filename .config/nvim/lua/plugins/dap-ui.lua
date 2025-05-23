local is_open = false

-- Manage DAP UI in a separate tab, so that the window layout is not affected.
-- The DAP UI tab will have only one window with the current buffer (cleaner).
local function open_dapui()
	local buffer = vim.api.nvim_get_current_buf()
	vim.cmd("tabnew")
	vim.api.nvim_set_current_buf(buffer)
	require("dapui").open()
	is_open = true
end

local function close_dapui()
	require("dapui").close()
	vim.cmd("tabclose")
	is_open = false
end

local function toggle_dapui()
	print("toggling")
	if is_open then
		close_dapui()
	else
		open_dapui()
	end
end

return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"nvim-neotest/nvim-nio", -- required
		"mfussenegger/nvim-dap",
	},
	config = function()
		require("dapui").setup()

		local dap = require("dap")
		dap.listeners.before.launch.dapui_config = open_dapui
		dap.listeners.before.event_terminated.dapui_config = close_dapui

		vim.keymap.set("n", "<Leader>du", toggle_dapui, { desc = "[d]ebug [U]I toggle" })
	end,
}
