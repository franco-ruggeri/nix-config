return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local which_key = require("which-key")
		which_key.setup()
		which_key.add({
			{ "<leader>a", group = "+[A]I" },
			{ "<leader>ap", group = "+[A]I [p]rompt" },
			{ "<leader>c", group = "+[c]ode" },
			{ "<leader>d", group = "+[d]ebug" },
			{ "<leader>f", group = "+[f]ind" },
			{ "<leader>g", group = "+[g]it" },
			{ "<leader>h", group = "+[h]arpoon" },
			{ "<leader>l", group = "+[l]atex" },
			{ "<leader>m", group = "+[m]arkdown" },
			{ "<leader>t", group = "+[t]asks|[t]ests|[t]odo comments" },
			{ "<leader>x", group = "+diagnostics" },
		})
	end,
}
