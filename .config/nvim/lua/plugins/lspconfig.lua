return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				local function map(mode, key, action, desc)
					vim.keymap.set(mode, key, action, { buffer = event.buf, desc = desc or "" })
				end

				local telescope = require("telescope.builtin")
				map("n", "gd", telescope.lsp_definitions, "[g]oto [d]efinition")
				map("n", "gD", vim.lsp.buf.declaration, "[g]oto [d]eclaration")
				map("n", "<leader>lr", vim.lsp.buf.rename, "[L]SP [r]ename")
				map("n", "<leader>lf", vim.lsp.buf.format, "[L]SP [f]ormat")

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = event.buf,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end,
		})
	end,
}
