-- General notes:
-- --------------------
-- For buffer linters, we use:
-- * multiple_files=false: With this flag, the generator does not clear diagnostics and keeps diagnostics of the open buffers.
--    Otherwise, there would be a problem when you switch to an already-open file (existing buffer). Specifically:
--    * Switching to a buffer doesn't trigger the LSP server to publish diagnostics.
--    * Therefore, no diagnostics would be shown until the buffer changes (trigger).
-- * method=DIAGNOSTICS: This method lints on buffer change. This is nice to see updated diagnostics while you work.
--
-- For workspace linters, we use:
-- * multiple_files=true: With this flag, the generator clears previous diagnostics to avoid duplicates.
-- * method=DIAGNOSTICS_ON_SAVE: This method lints only on save. This is important because:
--    * Since a workspace linter lints disk files, not buffers, we want buffers and disk files to be synced.
--      Otherwise, we would have outdated diagnostics shown for the updated buffers.
--    * It is an expensive operations, so we don't want to do it on every change.
-- --------------------

-- For Python linters, if in Python venv...
local python_env = {}
local python_prefer_local = nil
if vim.env.VIRTUAL_ENV then
	-- ... set PYTHONPATH so that Mason packages can see Python packages installed in venv
	python_env = { PYTHONPATH = vim.fn.glob(vim.env.VIRTUAL_ENV .. "/lib/python*/site-packages") }
	-- ... use venv binary over Mason binary when linter is installed in venv
	python_prefer_local = vim.env.VIRTUAL_ENV .. "/bin"
end

local sources = {
	linters_workspace = {},
	linters_buffer = {},
	others = {},
}
local lint_workspace = false

local function register_sources()
	local null_ls = require("null-ls")

	null_ls.reset_sources()

	local sources_active = {
		unpack(lint_workspace and sources.linters_workspace or sources.linters_buffer),
		unpack(sources.others),
	}

	-- Warning: don't use ipairs here, as the previous operations mess up the indices.
	for _, source in pairs(sources_active) do
		null_ls.register(source)
	end

	vim.diagnostic.reset()
end

local function toggle_linting_mode()
	lint_workspace = not lint_workspace
	register_sources()
end

local function add_pylint_buffer()
	local linter = require("null-ls").builtins.diagnostics.pylint.with({
		env = python_env,
		prefer_local = python_prefer_local,
	})
	table.insert(sources.linters_buffer, linter)
end

local function add_pylint_workspace()
	local null_ls = require("null-ls")
	local helpers = require("null-ls.helpers")

	local generator_opts = vim.tbl_extend("force", null_ls.builtins.diagnostics.pylint.generator.opts, {
		-- Multiple files so that every linting clears previous diagnostics. Otherwise, diagnostics would be duplicated.
		multiple_files = true,
		-- Same as default, but adding filename [*]. Otherwise, all the diagnostics would be assigned to the current buffer.
		on_output = helpers.diagnostics.from_json({
			attributes = {
				row = "line",
				col = "column",
				code = "symbol",
				severity = "type",
				message = "message",
				message_id = "message-id",
				symbol = "symbol",
				source = "pylint",
				filename = "path", -- [*] additional diagnostic attribute
			},
			severities = {
				convention = helpers.diagnostics.severities["information"],
				refactor = helpers.diagnostics.severities["information"],
			},
			offsets = {
				col = 1,
				end_col = 1,
			},
		}),
	})

	local linter = null_ls.builtins.diagnostics.pylint.with({
		method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
		generator_opts = generator_opts,
		env = python_env,
		prefer_local = python_prefer_local,
		args = {
			-- Defaults
			"--output-format",
			"json",
			-- Lint the whole workspace
			"$ROOT",
		},
	})

	table.insert(sources.linters_workspace, linter)
end

local function add_mypy_buffer()
	local null_ls = require("null-ls")

	local generator_opts = vim.tbl_extend("force", null_ls.builtins.diagnostics.mypy.generator.opts, {
		multiple_files = false, -- the default was true, strangely, see general notes
	})

	local linter = null_ls.builtins.diagnostics.mypy.with({
		env = python_env,
		prefer_local = python_prefer_local,
		generator_opts = generator_opts,
	})

	table.insert(sources.linters_buffer, linter)
end

local function add_mypy_workspace()
	local null_ls = require("null-ls")

	local linter = null_ls.builtins.diagnostics.mypy.with({
		method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
		env = python_env,
		prefer_local = python_prefer_local,
		args = {
			-- Defaults
			"--hide-error-codes",
			"--hide-error-context",
			"--no-color-output",
			"--show-absolute-path",
			"--show-column-numbers",
			"--show-error-codes",
			"--no-error-summary",
			"--no-pretty",
			-- Lint the whole workspace
			"$ROOT",
		},
		-- Since we don't lint the buffer, to_temp_file isn't necessary
		to_temp_file = false,
	})

	table.insert(sources.linters_workspace, linter)
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
		local null_ls = require("null-ls")

		mason_null_ls.setup({
			ensure_installed = {},
			automatic_installation = false,
			handlers = {
				function(source, types)
					for _, type in ipairs(types) do
						table.insert(sources.others, null_ls.builtins[type][source])
					end
				end,
				pylint = function()
					add_pylint_buffer()
					add_pylint_workspace()
				end,
				mypy = function()
					add_mypy_buffer()
					add_mypy_workspace()
				end,
			},
		})
		register_sources()
		vim.keymap.set("n", "<leader>xm", toggle_linting_mode, { desc = "Diagnostics [m]ode toggle" })
	end,
}
