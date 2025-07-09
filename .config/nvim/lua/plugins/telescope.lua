return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"nvim-tree/nvim-web-devicons", -- icons
		"folke/todo-comments.nvim", -- for integration with todo comments
		"nvim-telescope/telescope-ui-select.nvim", -- set vim.ui.select() to telescope
		"nvim-telescope/telescope-fzf-native.nvim", -- improves sorting performance
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
				"--hidden", -- include hidden files
			},
			file_ignore_patterns = {
				"%.git/", -- exclude .git/ (not ignored)
			},
		},
		pickers = {
			find_files = {
				hidden = true, -- include hidden files
				-- Set style similar to `fzf --tmux center`. Same experience as in command line.
				-- ====================
				layout_config = { width = 0.5, height = 0.5 },
				previewer = false,
				-- ====================
			},
		},
	},
	config = function(_, opts)
		opts.extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown(),
			},
		}

		local telescope = require("telescope")
		telescope.setup(opts)

		telescope.load_extension("ui-select")
		telescope.load_extension("fzf")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<Leader>ff", builtin.find_files, { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<Leader>fs", builtin.live_grep, { desc = "[f]ind [s]tring" })
		vim.keymap.set("n", "<Leader>fr", builtin.registers, { desc = "[f]ind [r]egister" })
		vim.keymap.set("n", "<Leader>ft", "<Cmd>TodoTelescope<CR>", { desc = "[f]ind [t]odo comment" })

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
