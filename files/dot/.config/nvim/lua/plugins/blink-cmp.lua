return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets", -- for snippets
	},
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
		completion = {
			menu = {
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind", gap = 1 },
						{ "source_name" },
					},
					components = {
						source_name = {
							text = function(ctx)
								return "[" .. ctx.source_name .. "]"
							end,
							highlight = "BlinkCmpLabel",
						},
					},
				},
			},
		},
	},
}
