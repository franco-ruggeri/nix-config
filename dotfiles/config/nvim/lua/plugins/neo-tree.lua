return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MunifTanjim/nui.nvim", -- required
		"nvim-tree/nvim-web-devicons", -- for file icons
	},
	opts = {
		filesystem = {
			hijack_netrw_behavior = "disabled",
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
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
