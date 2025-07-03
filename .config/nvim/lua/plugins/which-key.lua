return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local which_key = require("which-key")
		which_key.setup()
		which_key.add({
			{ "<Leader>a", group = "+[A]I", mode = { "n", "x" } },
			{ "<Leader>c", group = "+[c]ode" },
			{ "<Leader>d", group = "+[d]ebug" },
			{ "<Leader>f", group = "+[f]ind" },
			{ "<Leader>g", group = "+[g]it" },
			{ "<Leader>h", group = "+[h]arpoon" },
			{ "<Leader>l", group = "+[l]atex" },
			{ "<Leader>m", group = "+[m]arkdown" },
			{ "<Leader>t", group = "+[t]asks|[t]ests|[t]odo comments" },
			{ "<Leader>x", group = "+diagnostics" },
		})
	end,
}
