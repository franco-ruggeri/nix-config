return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets", -- for snippets
	},
	version = "1.*",
	opts = {
		signature = { enabled = true },
		sources = {
			per_filetype = {
				lua = { -- add lazydev for lua
					inherit_defaults = true,
					"lazydev",
				},
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
	},
}
