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
					for _, type in ipairs(types) do
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
						multiple_files = false, -- the default was wrongly true... this source lints one buffer at a time
					})

					null_ls.register(null_ls.builtins.diagnostics.mypy.with({
						env = python_env,
						prefer_local = python_prefer_local,
						generator_opts = generator_opts,
					}))
				end,
				prettier = function()
					local filetypes = null_ls.builtins.formatting.prettier.filetypes

					-- Remove markdown to avoid collisions with markdownlint
					local filetypes_new = {}
					for _, filetype in ipairs(filetypes) do
						if filetype ~= "markdown" then
							filetypes_new:insert(filetype)
						end
					end

					null_ls.register(null_ls.builtins.formatting.prettier.with({
						filetypes = filetypes_new,
					}))
				end,
			},
		})
	end,
}
