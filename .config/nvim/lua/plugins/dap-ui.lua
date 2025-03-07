return {
	"rcarriga/nvim-dap-ui",
	dependencies = {
		"nvim-neotest/nvim-nio", -- required
		"mfussenegger/nvim-dap",
	},
	config = function()
		local dapui = require("dapui")
		dapui.setup()

		local dap = require("dap")
		dap.listeners.before.attach.dapui_config = dapui.open
		dap.listeners.before.launch.dapui_config = dapui.open
		dap.listeners.before.event_terminated.dapui_config = dapui.close
		dap.listeners.before.event_exited.dapui_config = dapui.close

		vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "[d]ebug [U]I toggle" })
	end,
}
