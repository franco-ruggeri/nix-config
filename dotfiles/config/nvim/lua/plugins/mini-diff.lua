return {
	"nvim-mini/mini.diff",
	lazy = true,
	config = function()
		local diff = require("mini.diff")
		diff.setup({
			source = diff.gen_source.none(), -- for codecompanion.nvim
		})
	end,
}
