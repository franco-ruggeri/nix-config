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

		-- Some debug adapters do not support termination (e.g., OpenDebugAD7 for C++).
		-- In those cases, the termination event is not emitted and the DAP UI does not
		-- get closed. Thus, we close it explicitly.
		local function terminate_session()
			require("dap").terminate()
			dapui.close()
		end

		dap.listeners.before.launch.dapui_config = dapui.open
		dap.listeners.before.event_terminated.dapui_config = dapui.close

		vim.keymap.set("n", "<Leader>du", dapui.open, { desc = "[d]ebug [U]I open" })
		vim.keymap.set("n", "<Leader>dU", dapui.close, { desc = "[d]ebug [U]I close" })
		vim.keymap.set("n", "<Leader>dt", terminate_session, { desc = "[d]ebug [t]erminate" })
	end,
}
