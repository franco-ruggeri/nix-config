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

		-- For Python linters, if in Python venv...
		local python_env = {}
		local python_prefer_local = nil
		if vim.env.VIRTUAL_ENV then
			-- ... set PYTHONPATH so that Mason packages can see Python packages installed in venv
			python_env = { PYTHONPATH = vim.fn.glob(vim.env.VIRTUAL_ENV .. "/lib/python*/site-packages") }
			-- ... use venv binary over Mason binary when linter is installed in venv
			python_prefer_local = vim.env.VIRTUAL_ENV .. "/bin"
		end

		require("mason-null-ls").setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(source, types)
					for _, type in pairs(types) do
						null_ls.register(null_ls.builtins[type][source])
					end
				end,
				pylint = function()
					null_ls.register(null_ls.builtins.diagnostics.pylint.with({
						env = python_env,
						prefer_local = python_prefer_local,
					}))
				end,
				mypy = function()
					local generator_opts = vim.tbl_extend("force", null_ls.builtins.diagnostics.mypy.generator.opts, {
						multiple_files = false, -- the default is wrongly true... this source lints one buffer at a time
					})

					null_ls.register(null_ls.builtins.diagnostics.mypy.with({
						env = python_env,
						prefer_local = python_prefer_local,
						generator_opts = generator_opts,
					}))
				end,
				-- Register prettier twice:
				-- * For Markdown files, use `--prose-wrap always` to wrap lines.
				-- * For all other filetypes, use the default prettier settings.
				prettier = function()
					null_ls.register(null_ls.builtins.formatting.prettier.with({
						filetypes = { "markdown" },
						extra_args = { "--prose-wrap", "always" }, -- wrap lines in Markdown files
					}))
					null_ls.register(null_ls.builtins.formatting.prettier.with({
						filetypes = vim.tbl_filter(function(ft)
							return ft ~= "markdown"
						end, null_ls.builtins.formatting.prettier.filetypes),
					}))
				end,
				markdownlint = function()
					-- Register only for diagnostics, not formatting, because formatting is handled by prettier
					null_ls.register(null_ls.builtins.diagnostics.markdownlint)
				end,
			},
		})
	end,
}
