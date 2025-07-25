local function to_kebab_case(str)
	-- Replace non-alphanumeric with spaces, then convert spaces to hyphens
	str = str:gsub("[^%w]+", " ")
	str = str:lower():gsub("%s+", "-")
	return str
end

-- TODO: find a consistent format for links in marksman, it should work on quartz, obsidian, and neovim...
--  - backlinks don't work
--  - marksman uses only the title, but Obsidian uses [[path|alias]]
--  maybe I should use obsidian for linking and force Markdown links in marksman...
-- TODO: figure out if I should use the ID or not... Obsidian.nvim uses it in extract_note
return {
	"obsidian-nvim/obsidian.nvim",
	lazy = true, -- load on demand from specific projects via .nvim.lua
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for better rendering
		"nvim-telescope/telescope.nvim", -- for pickers
	},
	opts = {
		workspaces = {
			{ name = "notes", path = vim.fn.getcwd },
		},
		new_notes_location = "notes_subdir",
		notes_subdir = "0-inbox",
		-- TODO: try templates
		templates = {
			folder = "_assets/templates",
		},
		backlinks = {
			parse_headers = false,
		},
		attachments = {
			img_folder = "_assets/attachments",
			img_name_func = function()
				return ("pasted-image-%s"):format(os.date("%Y%m%d%H%M%S"))
			end,
			-- TODO: should URL encode it as recommended by Obsidian,check default implementation
			img_text_func = function(client, path)
				-- TODO: on new release >3.12, the function will change signature to `function(path)`
				-- Without the client, I'll need to find another way to extract the path relative to the vault
				-- Start by checking the built-in function at https://github.com/obsidian-nvim/obsidian.nvim/blob/main/lua/obsidian/builtin.lua#L103
				path = client:vault_relative_path(path)
				return ("![%s](%s)"):format(path.name, tostring(path))
			end,
			confirm_img_paste = false,
		},
		completion = { -- marksman takes care of completion via LSP
			nvim_cmp = false,
			blink = false,
		},
		mappings = {}, -- no smart action and no `gf` (provided by marksman)
		ui = { enable = false }, -- render-markdown takes care of nice rendering
		-- Based on defaults, but removing:
		-- * The note ID (unnecessary)
		-- * The title as an alias. Marksman already does this implicitly.
		note_frontmatter_func = function(note)
			local out = { aliases = note.aliases, tags = note.tags }
			for k, v in pairs(note.metadata or {}) do
				out[k] = v
			end

			-- Remove title from aliases (obsidian.nvim adds it on new note)
			out.aliases = vim.tbl_filter(function(alias)
				return alias ~= note.title
			end, out.aliases)

			return out
		end,
		note_path_func = function(spec)
			spec.title = spec.title or spec.id
			local path = spec.dir / to_kebab_case(tostring(spec.title))
			return path:with_suffix(".md")
		end,
	},
	config = function(_, opts)
		require("obsidian").setup(opts)

		-- TODO: think again about these keymaps...
		-- most of these functions are actually "find commands", should I use <Leader>f?
		vim.keymap.set("n", "<Leader>ob", "<Cmd>Obsidian backlinks<CR>", { desc = "[o]bsidian [b]acklinks" })
		vim.keymap.set("x", "<Leader>ol", "<Cmd>Obsidian link<CR>", { desc = "[o]bsidian add [l]ink" })
		vim.keymap.set("n", "<Leader>ol", "<Cmd>Obsidian links<CR>", { desc = "[o]bsidian [l]inks" })
		vim.keymap.set("n", "<Leader>op", "<Cmd>Obsidian paste_img <CR>", { desc = "[o]bsidian [p]aste image" })

		vim.keymap.set("n", "<Leader>ff", "<Cmd>Obsidian quick_switch<CR>", { desc = "[f]ind [f]ile" })
		vim.keymap.set("n", "<Leader>fs", "<Cmd>Obsidian search<CR>", { desc = "[f]ind [s]tring" })
		vim.keymap.set("n", "<Leader>ft", "<Cmd>Obsidian tags<CR>", { desc = "[f]ind [t]ag" })

		vim.keymap.set("n", "<Leader>on", "<Cmd>Obsidian new<CR>", { desc = "[o]bsidian new [n]ote" })
		vim.keymap.set("x", "<Leader>on", "<Cmd>Obsidian extract_note<CR>", { desc = "[o]bsidian extract [n]ote" })
		vim.keymap.set(
			"n",
			"<Leader>oN",
			"<Cmd>Obsidian new_from_template<CR>",
			{ desc = "[o]bsidian new [n]ote from template" }
		)
	end,
}
