local utils = require("utils")

return {
	"neovim/nvim-lspconfig",
	config = function()
		utils.lsp.setup_on_attach()
	end,
}
