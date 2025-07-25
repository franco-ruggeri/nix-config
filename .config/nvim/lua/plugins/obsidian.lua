local function to_kebab_case(str)
	-- Replace non-alphanumeric with spaces, then convert spaces to hyphens
	str = str:gsub("[^%w]+", " ")
	str = str:lower():gsub("%s+", "-")
	return str
end

return {
	"obsidian-nvim/obsidian.nvim",
	lazy = true, -- load on demand from specific projects via .nvim.lua
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for better rendering
	},
	opts = {
		workspaces = {
			{ name = "notes", path = vim.fn.getcwd },
		},
		new_notes_location = "notes_subdir",
		notes_subdir = "0-inbox",
		-- Based on defaults, but removing:
		-- * The note ID (unnecessary)
		-- * The title as an alias. Marksman already does this implicitly.
		note_frontmatter_func = function(note)
			local out = { aliases = note.aliases, tags = note.tags }
			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for k, v in pairs(note.metadata) do
					out[k] = v
				end
			end
			return out
		end,
		note_path_func = function(spec)
			local path = spec.dir / to_kebab_case(tostring(spec.title))
			return path:with_suffix(".md")
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
