return {
	"rcarriga/nvim-dap-ui",
	version = false, -- latest commit, see https://github.com/rcarriga/nvim-dap-ui/issues/343
	dependencies = {
		"nvim-neotest/nvim-nio", -- required
		"mfussenegger/nvim-dap",
		"nvim-neotest/neotest", -- [*]
		"folke/edgy.nvim", -- [*]
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

			-- HACK: [*] Scenario: See below.
			-- edgy.nvim loses track of its managed windows when new tabs are
			-- created/closed. Thus, at this point, edgy.nvim does not have the
			-- neotest summary window registered anymore. In order for `goto_main()`
			-- to work (see below), we toggle the neotest summary window twice. If
			-- the neotest summary window was open, it will be closed and re-opened
			-- so that edgy.nvim registers it.
			local neotest = require("neotest")
			neotest.summary.toggle()
			neotest.summary.toggle()
		end
		local function open_dapui()
			close_dapui() -- support opening DAP UI multiple times

			-- [*] Scenario: Test launched in debugging mode from the neotest
			-- summary window. The neotest summary window is managed by edgy.nvim. If
			-- we open the DAP UI around this window, the layout becomes a mess.
			-- Thus, we jump to the main window using edgy.nvim.
			require("edgy").goto_main()

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
