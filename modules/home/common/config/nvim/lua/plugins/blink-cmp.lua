return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets", -- for snippets
		{
			"Kaiser-Yang/blink-cmp-avante", -- for Avante integration
			version = false, -- latest commit, otherwise it doesn't work for slash commands
		},
	},
	opts = {
		signature = { enabled = true },
		sources = {
			per_filetype = {
				lua = { -- add lazydev for lua
					inherit_defaults = true,
					"lazydev",
				},
				AvanteInput = {
					inherit_defaults = true,
					"avante",
				},
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				avante = {
					name = "Avante",
					module = "blink-cmp-avante",
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
