local null_ls = require("null-ls")

for _, language_server in pairs({
	"lua_ls",
	"bashls",
	"marksman",
	"jsonls",
	"yamlls",
	"taplo",
	"lemminx",
	"nil_ls",
}) do
	vim.lsp.enable(language_server)
end

for _, formatter in pairs({
	"stylua",
	"shfmt",
	"prettier",
	"prettier_markdown",
}) do
	null_ls.register(null_ls.builtins.formatting[formatter])
end

for _, linter in pairs({
	"markdownlint",
}) do
	null_ls.register(null_ls.builtins.diagnostics[linter])
end
