return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for linters and formatters
		"nvimtools/none-ls.nvim",
		"nvim-lua/plenary.nvim", -- required
		"nvim-telescope/telescope.nvim", -- for LSP pickers (used in on_attach)
	},
	config = function()
		local null_ls = require("null-ls")
		local mason_null_ls = require("mason-null-ls")
		local is_venv = vim.env.VIRTUAL_ENV ~= nil

		mason_null_ls.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				-- Default handler: nothing special, just use the default setup
				function(source_name, methods)
					mason_null_ls.default_setup(source_name, methods)
				end,

				-- Always use formatters, preferring the binary from the venv.
				-- Reason: formatting can be done from outside venv and it is always useful.
				black = function()
					local overrides = {}
					if is_venv then
						overrides["command"] = vim.env.VIRTUAL_ENV .. "/bin/black"
					end
					null_ls.register(null_ls.builtins.formatting.black.with(overrides))
				end,

				-- Use linters only if installed in the venv and using the binary from the venv.
				-- Reasons:
				-- - Linting requires to see installed packages and configs in pyproject.toml.
				-- - Linting is not always desirable (e.g., quick scripts).
				pylint = function()
					if is_venv then
						local overrides = { command = vim.env.VIRTUAL_ENV .. "/bin/pylint" }
						null_ls.register(null_ls.builtins.diagnostics.pylint.with(overrides))
					end
				end,
				mypy = function()
					if is_venv then
						local overrides = { command = vim.env.VIRTUAL_ENV .. "/bin/mypy" }
						null_ls.register(null_ls.builtins.diagnostics.mypy.with(overrides))
					end
				end,
			},
		})
	end,
}
