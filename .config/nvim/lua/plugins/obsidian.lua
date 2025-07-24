local vault_path = vim.fn.expand("~/codebase/notes")

-- TODO: don't create ID in front matter
return {
	"obsidian-nvim/obsidian.nvim",
	event = {
		("BufReadPre %s/*.md"):format(vault_path),
		("BufNewFile %s/*.md"):format(vault_path),
	},
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for better rendering
	},
	opts = {
		-- TODO: create new note in 0-inbox
		workspaces = {
			{
				name = "notes",
				path = vault_path,
			},
		},
		-- TODO: try templates
		-- TODO: move _assets to .assets
		templates = {
			folder = "_assets/templates",
		},
		attachments = {
			img_folder = "_assets/attachments",
		},
		completion = { -- marksman takes care of completion via LSP
			nvim_cmp = false,
			blink = false,
		},
		ui = {
			enable = false, -- render-markdown takes care of nice rendering
		},
	},
	config = function(_, opts)
		require("obsidian").setup(opts)

		-- TODO: set keymaps
	end,
}
