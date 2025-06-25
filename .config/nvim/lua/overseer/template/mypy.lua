local utils = require("utils")

-- Based on https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/diagnostics/mypy.lua
return {
	name = "mypy",
	builder = function()
		return {
			name = "mypy",
			cmd = "mypy",
			args = {
				"--hide-error-context",
				"--no-color-output",
				"--show-absolute-path",
				"--show-column-numbers",
				"--show-error-codes",
				"--no-error-summary",
				"--no-pretty",
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
							"lnum",
							"col",
							"type",
							"text",
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
