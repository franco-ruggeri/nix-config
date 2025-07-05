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

		-- Remove current item, shift the rest, and select the next
		vim.keymap.set("n", "<Leader>hr", function()
			local list = harpoon:list()
			local item_to_remove = list.config:create_list_item()
			local item_idx = nil
			local length = list:length()
			for i = 1, length do
				local item = list:get(i)
				if not item_idx and list.config.equals(item, item_to_remove) then
					item_idx = i
				end
				if item_idx then
					if i < length then -- shift
						list:replace_at(i, list:get(i + 1))
					else
						list:remove_at(i)
					end
				end
			end
			list:select(item_idx)
		end, { desc = "[h]arpoon [r]emove file" })

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
