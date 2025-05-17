return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"nvim-tree/nvim-web-devicons", -- icons
		{
			"nvim-telescope/telescope-fzf-native.nvim", -- improves sorting performance
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
	},
	config = function()
		require("telescope").setup({})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "[f]ind [g]it file" })
		vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "[f]ind [s]tring" })
	end,
}
