-- TODO: check if capabilities are set correctly
-- See https://cmp.saghen.dev/installation.html#lsp-capabilities
return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets", -- for snippets
	},
	version = "1.*",
	opts = {
		signature = { enabled = true },
	},
}
