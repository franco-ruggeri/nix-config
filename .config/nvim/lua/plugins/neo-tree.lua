local function avante_add_file(state)
	local node = state.tree:get_node()
	local filepath = node:get_id()
	local relative_path = require("avante.utils").relative_path(filepath)
	local sidebar = require("avante").get()

	-- Opne Avante sidebar if not already open
	local open = sidebar:is_open()
	if not open then
		require("avante.api").ask()
		sidebar = require("avante").get()
	end

	-- Add the selected file to the Avante sidebar
	sidebar.file_selector:add_selected_file(relative_path)

	-- Remove neo tree buffer
	if not open then
		sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
	end
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MunifTanjim/nui.nvim", -- required
		"nvim-tree/nvim-web-devicons", -- for file icons
		"yetone/avante.nvim", -- for Avante integration
	},
	opts = {
		filesystem = {
			hijack_netrw_behavior = "disabled",
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
			},
			-- Neo-tree integration for adding files to Avante context
			-- Based on https://github.com/yetone/avante.nvim?tab=readme-ov-file#neotree-shortcut
			commands = {
				avante_add_file = avante_add_file,
			},
			window = {
				mappings = {
					["oa"] = "avante_add_file",
				},
			},
		},
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)

		-- If the current buffer is a file, open Neo-tree in reveal mode.
		-- Otherwise, just open Neo-tree.
		local function open()
			local bufname = vim.api.nvim_buf_get_name(0)
			local stat = vim.uv.fs_stat(bufname)
			if stat and stat.type == "file" then
				vim.cmd("Neotree reveal")
			else
				vim.cmd("Neotree")
			end
		end

		vim.keymap.set("n", "<Leader>e", open, { desc = "[e]xplore files" })
	end,
}
