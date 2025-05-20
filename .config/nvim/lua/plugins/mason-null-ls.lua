local function register_in_venv(type, tool)
	-- Check if a venv is active
	if vim.env.VIRTUAL_ENV == nil then
		return
	end

	-- Check if source is installed in venv
	local bin_path = vim.env.VIRTUAL_ENV .. "/bin/" .. tool
	if vim.fn.executable(bin_path) == 0 then
		return
	end

	-- Register the source with the venv command
	local null_ls = require("null-ls")
	null_ls.register(null_ls.builtins[type][tool].with({
		command = bin_path,
	}))
end

return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for linters and formatters
		"nvimtools/none-ls.nvim",
		"nvim-lua/plenary.nvim", -- required
		"nvim-telescope/telescope.nvim", -- for LSP pickers (used in on_attach)
	},
	config = function()
		local mason_null_ls = require("mason-null-ls")

		mason_null_ls.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				-- Default handler: nothing special, just use the default setup
				function(source_name, methods)
					mason_null_ls.default_setup(source_name, methods)
				end,

				-- Use code quality tools only if installed in the venv.
				-- Use the binary from the venv, so that:
				-- - Tools see installed packages.
				-- - Tools use the config in pyproject.toml.
				pylint = function()
					register_in_venv("diagnostics", "pylint")
				end,
				mypy = function()
					register_in_venv("diagnostics", "mypy")
				end,
				black = function()
					register_in_venv("formatting", "black")
				end,
			},
		})
	end,
}
