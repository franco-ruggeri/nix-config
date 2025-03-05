return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for LSP servers
		"williamboman/mason-lspconfig.nvim", -- automates the LSP client setup
		"hrsh7th/cmp-nvim-lsp", -- provides extra capabilities for autocompletion
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				local telescope = require("telescope.builtin")
				vim.keymap.set(
					"n",
					"gd",
					telescope.lsp_definitions,
					{ buffer = event.buf, desc = "[g]oto [d]efinition" }
				)
				vim.keymap.set(
					"n",
					"gD",
					vim.lsp.buf.declaration,
					{ buffer = event.buf, desc = "[g]oto [d]eclaration" }
				)
				vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = event.buf, desc = "[L]SP [r]ename" })
				vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, { buffer = event.buf, desc = "[L]SP [f]ormat" })
				vim.keymap.set("v", "=", vim.lsp.buf.format, { buffer = event.buf })

				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = event.buf,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end,
		})

		-- Automatic configuration of LSP client for each LSP server installed with Mason.
		require("mason-lspconfig").setup()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		require("mason-lspconfig").setup_handlers({
			function(server_name)
				require("lspconfig")[server_name].setup({ capabilities = capabilities })
			end,
		})
	end,
}
