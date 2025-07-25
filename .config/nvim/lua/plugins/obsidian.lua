return {
	"obsidian-nvim/obsidian.nvim",
	lazy = true, -- load on demand from specific projects via .nvim.lua
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for better rendering
	},
	opts = {
		-- TODO: create new note in 0-inbox
		workspaces = {
			{
				name = "notes",
				path = vim.fn.getcwd,
			},
		},
		-- Based on defaults, but removing the `id` field
		note_frontmatter_func = function(note)
			if note.title then
				note:add_alias(note.title)
			end
			local out = { aliases = note.aliases, tags = note.tags }
			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for k, v in pairs(note.metadata) do
					out[k] = v
				end
			end
			return out
		end,
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
