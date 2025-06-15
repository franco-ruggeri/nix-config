return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for debug adapters
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python", -- default config for debugpy
	},
	config = function()
		local mason_dap = require("mason-nvim-dap")
		local dap = require("dap")

		mason_dap.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(config)
					mason_dap.default_setup(config)
				end,
				-- dap-python provides better default configurations than mason-nvim-dap
				python = function()
					require("dap-python").setup(vim.env.MASON .. "/packages/debugpy/venv/bin/python")
				end,
				-- There are two main javascript debug adapters:
				-- * node2: no longer maintained.
				-- * js-debug: the modern alternative, maintained.
				--
				-- mason-nvim-dap provides a default setup for node2, but not for js-debug.
				-- See https://github.com/jay-babu/mason-nvim-dap.nvim/issues/127
				--
				-- Thus, we set up js-debug using the recommended configuration from nvim-dap's wiki.
				-- See https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#javascript
				js = function()
					dap.adapters["pwa-node"] = {
						type = "server",
						host = "localhost",
						port = "${port}",
						executable = {
							command = "node",
							args = {
								vim.env.MASON .. "/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
								"${port}",
							},
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
				end,
			},
		})
	end,
}
