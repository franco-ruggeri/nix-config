local utils = require("utils")

-- Based on https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/diagnostics/pylint.lua
return {
	name = "pylint",
	builder = function()
		return {
			name = "pylint",
			cmd = "pylint",
			args = {
				"--output-format",
				"json",
				"--ignore",
				".venv",
				".",
			},
			components = {
				{
					"on_output_parse",
					parser = {
						diagnostics = {
							"sequence",
							{
								{ "skip_until", "{" },
								{
									"extract",
									{ append = false },
									'"type": "([^"]+)"',
									"type",
								},
								{ "skip_lines", 2 },
								{
									"extract",
									{ append = false },
									'"line": (%d+)',
									"lnum",
								},
								{
									"extract",
									{ append = false },
									'"column": (%d+)',
									"col",
								},
								{ "skip_lines", 2 },
								{
									"extract",
									{ append = false },
									'"path": "([^"]+)"',
									"filename",
								},
								{
									"extract",
									{ append = false },
									'"symbol": "([^"]+)"',
									"code",
								},
								{
									"extract",
									'"message": "([^"]+)"',
									"text",
								},
							},
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
			return utils.is_python_project(opts.dir) and vim.fn.executable("pylint") == 1
		end,
	},
}
