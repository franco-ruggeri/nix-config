return {
	"jay-babu/mason-nvim-dap.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for debug adapters
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python", -- default config for debugpy
	},
	config = function()
		local mason_dap = require("mason-nvim-dap")
		mason_dap.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(config)
					mason_dap.default_setup(config)
				end,
				-- Special handler for python. We use dap-python to have better default config.
				-- Since dap-python takes care of the setup, we don't need to call:
				-- `require("mason-nvim-dap").default_setup(config)`
				python = function()
					local debugpy_path = vim.fn.expand("$MASON/packages/debugpy")
					require("dap-python").setup(debugpy_path .. "/venv/bin/python")
				end,
			},
		})
	end,
}
