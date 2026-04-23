return {
	"rcarriga/nvim-dap-ui",
	version = false, -- latest commit, see https://github.com/rcarriga/nvim-dap-ui/issues/343
	dependencies = {
		"nvim-neotest/nvim-nio", -- required
		"mfussenegger/nvim-dap",
	},
	config = function()
		local dapui = require("dapui")
		local dap = require("dap")

		dapui.setup()

		-- Manage DAP UI in a separate tab, so that the window layout is not affected.
		-- The DAP UI tab will have only one window with the current buffer (cleaner).
		local function close_dapui()
			-- On DAP UI close, we return to the first tab and close all other tabs.
			-- We avoid storing the DAP UI status, as the tab can be closed manually,
			-- bypassing the DAP UI close function.
			vim.cmd("tabfirst")
			vim.cmd("tabonly")
		end
		local function open_dapui()
			close_dapui() -- support opening DAP UI multiple times

			local buffer = vim.api.nvim_get_current_buf()
			vim.cmd("tabnew")
			vim.api.nvim_set_current_buf(buffer)
			dapui.open()
		end

		-- Some debug adapters do not support termination (e.g., OpenDebugAD7 for C++).
		-- In those cases, the termination event is not emitted and the DAP UI does not
		-- get closed. Thus, we close it explicitly.
		local function terminate_session()
			require("dap").terminate()
			close_dapui()
		end

		dap.listeners.before.launch.dapui_config = open_dapui
		dap.listeners.before.event_terminated.dapui_config = close_dapui

		vim.keymap.set("n", "<Leader>du", open_dapui, { desc = "[d]ebug [U]I open" })
		vim.keymap.set("n", "<Leader>dU", close_dapui, { desc = "[d]ebug [U]I close" })
		vim.keymap.set("n", "<Leader>dt", terminate_session, { desc = "[d]ebug [t]erminate" })
	end,
}
