return {
	"jbyuki/nabla.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	ft = "markdown",
	config = function()
		local nabla = require("nabla")
		nabla.enable_virt()
		vim.keymap.set("n", "<Leader>ll", nabla.popup, { desc = "[l]atex popup" })
		vim.keymap.set("n", "<Leader>lv", nabla.toggle_virt, { desc = "[l]atex [v]irtual lines" })
	end,
}
