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
	opts = {
		defaults = {
			vimgrep_arguments = {
				-- Defaults (:h telescope.defaults.vimgrep_arguments)
				-- ====================
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				-- ====================
				"--no-ignore", -- include files ignored by .gitignore
				"--hidden", -- include hidden files
			},
			file_ignore_patterns = {
				"node_modules",
				".git",
			},
		},
	},
	config = function(_, opts)
		require("telescope").setup(opts)

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "[f]ind [g]it file" })
		vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "[f]ind [s]tring" })

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Bind LSP methods to Telescope",
			callback = function(args)
				vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = args.buf, desc = "[g]oto [d]efinition" })
				vim.keymap.set(
					{ "n", "x" },
					"grr",
					builtin.lsp_references,
					{ buffer = args.buf, desc = "[g]oto [r]eferences" }
				)
			end,
		})
	end,
}
