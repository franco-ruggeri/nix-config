return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MunifTanjim/nui.nvim", -- required
		"nvim-tree/nvim-web-devicons", -- for file icons
		--  TODO:I think I'll set it up for notes, if so uncomment it
		-- {"3rd/image.nvim", opts = {}}, -- Optional image support in preview window: See `# Preview Mode` for more information
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

		local function open()
			local bufname = vim.api.nvim_buf_get_name(0)
			local stat = vim.uv.fs_stat(bufname)

			if stat and stat.type == "file" then
				vim.cmd("Neotree reveal position=current")
			else
				vim.cmd("Neotree position=current")
			end
		end

		vim.keymap.set("n", "<leader>e", open, { desc = "[e]xplore files (tree)" })
	end,
}
