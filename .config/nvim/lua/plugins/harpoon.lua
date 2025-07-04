return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		settings = {
			save_on_toggle = true,
			save_on_ui_close = true,
		},
	},
	config = function(_, opts)
		local harpoon = require("harpoon")
		harpoon:setup(opts)

		vim.keymap.set("n", "<Leader>ha", function()
			harpoon:list():add()
		end, { desc = "[h]arpoon [a]dd file" })

		vim.keymap.set("n", "<Leader>hh", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "[h]arpoon menu toggle" })

		for i = 1, 9 do
			vim.keymap.set("n", ("<M-%d>"):format(i), function()
				harpoon:list():select(i)
			end, { noremap = true, desc = ("[h]arpoon [%d]-th buffer"):format(i) })
		end
	end,
}
