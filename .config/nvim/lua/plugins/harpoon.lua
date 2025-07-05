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

		vim.keymap.set("n", "<Leader>hr", function()
			local buffer = vim.api.nvim_buf_get_name(0)
			local list = harpoon:list()

			-- Remove item from the list if present
			local item = list:get_by_value(buffer)
			list:remove(item)

			-- Remove gaps from the list
			-- Note: list:length() is the index of the last item
			local empty_indices = {} -- indices with gaps in the initial list
			local empty_indices_next = nil -- first index in empty_indices that has not been filled yet
			for i = 1, list:length() do
				local item = list:get(i)
				if item and empty_indices_next then
					local empty_idx = empty_indices[empty_indices_next]
					if empty_idx ~= i then
						list:replace_at(empty_idx, item)
						list:remove_at(i)
					end
					empty_indices_next = empty_indices_next + 1
				else
					table.insert(empty_indices, i)
					empty_indices_next = empty_indices_next and empty_indices_next + 1 or 1
				end
			end
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
