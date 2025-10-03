local constants = require("utils").constants
local open_debug_ad7 = constants.VSCODE_CPPTOOLS
	.. "/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7"

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"mfussenegger/nvim-dap-python", -- default config for debugpy
		"stevearc/overseer.nvim", -- for running preLaunchTask
	},
	config = function()
		local dap = require("dap")

		vim.keymap.set("n", "<F5>", dap.continue)
		vim.keymap.set("n", "<F10>", dap.step_over)
		vim.keymap.set("n", "<F11>", dap.step_into)
		vim.keymap.set("n", "<F12>", dap.step_out)
		vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "[d]ebug [b]reakpoint toggle" })
		vim.keymap.set("n", "<Leader>dB", dap.clear_breakpoints, { desc = "[d]ebug [b]reakpoint clear" })
		vim.keymap.set("n", "<Leader>dr", dap.continue, { desc = "[d]ebug [r]un continue" })
		vim.keymap.set("n", "<Leader>dR", dap.run_last, { desc = "[d]ebug [r]un last" })

		-- Python
		require("dap-python").setup("debugpy-adapter")

		-- TODO: I can wrap the configs below in a plugin "dapconfig", similar to lspconfig

		-- Javascript
		-- See https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = { "jsdebug", "${port}" },
			},
		}
		dap.configurations.javascript = {
			{
				type = "pwa-node",
				request = "launch",
				name = "Launch file",
				program = "${file}",
				cwd = "${workspaceFolder}",
			},
		}

		-- C/C++
		-- Based on https://codeberg.org/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
		-- However, we also compile before debugging using preLaunchTask with overseer.nvim.
		dap.adapters.cppdbg = {
			id = "cppdbg",
			type = "executable",
			command = open_debug_ad7,
		}
		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopAtEntry = true,
				preLaunchTask = "cmake",
			},
			{
				name = "Launch file (args)",
				type = "cppdbg",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				args = function()
					return vim.split(vim.fn.input("Args: "), " +", { trimempty = true })
				end,
				stopAtEntry = true,
				preLaunchTask = "cmake",
			},
		}
	end,
}
