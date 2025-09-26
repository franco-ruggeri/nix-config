return {
	"nvimtools/none-ls.nvim", -- maintained fork of null-ls
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup()

		local diagnostics = null_ls.builtins.diagnostics
		local formatting = null_ls.builtins.formatting

		-- For Python linters, if in Python venv...
		local python_env = {}
		local python_prefer_local = nil
		if vim.env.VIRTUAL_ENV then
			-- ... set PYTHONPATH so that Mason packages can see Python packages installed in venv
			python_env = { PYTHONPATH = vim.fn.glob(vim.env.VIRTUAL_ENV .. "/lib/python*/site-packages") }
			-- ... use venv binary over Mason binary when linter is installed in venv
			python_prefer_local = vim.env.VIRTUAL_ENV .. "/bin"
		end

		diagnostics.pylint = diagnostics.pylint.with({
			env = python_env,
			prefer_local = python_prefer_local,
		})

		diagnostics.mypy = diagnostics.mypy.with({
			env = python_env,
			prefer_local = python_prefer_local,
			generator_opts = vim.tbl_extend("force", diagnostics.mypy.generator.opts, {
				multiple_files = false, -- the default is wrongly true... this source lints one buffer at a time
			}),
		})

		-- Remove Markdown from default prettier
		formatting.prettier = formatting.prettier.with({
			filetypes = vim.tbl_filter(function(ft)
				return ft ~= "markdown"
			end, null_ls.builtins.formatting.prettier.filetypes),
		})

		-- Specificalized prettier with prose wrap for Markdown files
		formatting.prettier_markdown = formatting.prettier.with({
			filetypes = { "markdown" },
			extra_args = { "--prose-wrap", "always" },
		})

		-- Prettier wraps lines at 80 where possible. In some cases (e.g., long links), it is not possible.
		-- Markdownlint would nevertheless complain about these lines. Disable the line-length rule.
		diagnostics.markdownlint = diagnostics.markdownlint.with({
			extra_args = { "--disable", "MD013" },
		})
	end,
}
