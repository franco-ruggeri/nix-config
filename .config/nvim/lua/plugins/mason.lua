return {
	"williamboman/mason.nvim",
	lazy = true,
	config = function()
		require("mason").setup()

		local mason_registry = require("mason-registry")
		for _, mason_package in ipairs({
			-- Lua
			"lua-language-server", -- language server
			"stylua", -- formatter

			-- Bash
			"bash-language-server", -- language server
			"shfmt", -- formatter

			-- Markdown
			"marksman", -- language server
			"markdownlint", -- linter
			"prettier", -- formatter

			-- JSON
			"json-lsp", -- language server with linter
			"prettier", -- formatter

			-- YAML
			"yaml-language-server", -- language server
			"prettier", -- formatter

			-- TOML
			"taplo", -- language server with formatter

			-- XML
			"lemminx", -- language server with formatter

			-- Helm
			"helm-ls", -- language server

			-- Docker
			"dockerfile-language-server", -- language server
			"hadolint", -- linter

			-- Python
			"python-lsp-server", -- language server
			"ruff", -- linter and formatter
			"pylint", -- linter (some rules not covered by ruff, see https://github.com/astral-sh/ruff/issues/970)
			"mypy", -- linter (static type checker)

			-- C/C++
			"clangd", -- language server
			"clang-format", -- formatter
			"cpptools", -- debug adapter

			-- TypeScript and JavaScript
			"typescript-language-server", -- language server
			"prettier", -- formatter

			-- LaTeX
			"texlab", -- language server with formatter

			-- Java
			"jdtls", -- language server
			"google-java-format", -- formatter
			"java-debug-adapter", -- debug adapter
			"java-test", -- use debug adapter on tests
		}) do
			if not mason_registry.is_installed(mason_package) then
				vim.cmd("MasonInstall " .. mason_package)
			end
		end
	end,
}
