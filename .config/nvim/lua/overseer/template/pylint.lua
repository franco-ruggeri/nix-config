local utils = require("utils")

-- Based on https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/diagnostics/pylint.lua
return {
	name = "pylint",
	builder = function()
		return {
			cmd = "pylint",
			args = {
				"--ignore",
				".venv",
				".",
			},
			components = {
				{
					"on_output_parse",
					parser = {
						diagnostics = {
							"extract",
							"([^:]+):(%d+):(%d+): (%a+): (.*)  %[([%a-]+)%]",
							"filename",
							"row",
							"col",
							"severity",
							"message",
							"code",
						},
					},
				},
				{ "on_result_diagnostics" },
				{ "default" },
			},
		}
	end,
	condition = {
		callback = function(opts)
			return utils.is_python_project(opts.dir)
		end,
	},
}
