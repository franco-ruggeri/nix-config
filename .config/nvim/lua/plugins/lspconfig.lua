return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.config("pylsp", {
			settings = {
				pylsp = {
					plugins = {
						pyflakes = { enabled = false },
						autopep8 = { enabled = false },
						mccabe = { enabled = false },
						pycodestyle = { enabled = false },
						yapf = { enabled = false },
					},
				},
			},
		})
	end,
}
