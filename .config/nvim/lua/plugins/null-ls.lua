local utils = require("utils")

return {
	"nvimtools/none-ls.nvim", -- maintained fork of null-ls
	opts = {
		on_attach = utils.lsp.setup_on_attach(),
	},
}
