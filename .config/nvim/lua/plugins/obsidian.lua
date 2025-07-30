local function to_kebab_case(str)
	str = str:gsub("[^%w]+", " ") -- non-alphanumeric -> space
	str = str:lower():gsub("%s+", "-") -- spaces -> "-"
	return str
end

local function open_note()
	local open_cmd = vim.uv.os_uname().sysname == "Darwin" and "open" or "xdg-open"

	local full_path = vim.api.nvim_buf_get_name(0)
	local note_path = vim.fn.fnamemodify(full_path, ":.:r")
	local url = ("https://www.brain.ruggeri.ddnsfree.com/%s"):format(note_path)

	local cmd = ('%s "%s"'):format(open_cmd, url)
	vim.fn.system(cmd)
end

-- Based on defaults, but removing the note ID and title (unnecessary)
local note_frontmatter_func = function(note)
	local out = { aliases = note.aliases, tags = note.tags }
	out.aliases = vim.tbl_filter(function(alias)
		return alias ~= note.title
	end, out.aliases)
	return out
end

-- Use kebab-case title for the filename. By default, the note ID is used.
local function note_path_func(spec)
	spec.title = spec.title or spec.id
	local path = spec.dir / to_kebab_case(tostring(spec.title))
	return path:with_suffix(".md")
end

-- Use kebab-case timestamp. By default, "Pasted image %Y%m%d%H%M%S" is used.
local function img_name_func()
	return ("pasted-image-%s"):format(os.date("%Y%m%d%H%M%S"))
end

-- Use the vault-relative path in the image link.
-- By default, the link is created with only the filename.
local function img_text_func(path)
	local util = require("obsidian.util")
	path = tostring(path:vault_relative_path())
	path = util.urlencode(path, { keep_path_sep = true })
	return ("![pasted image](%s)"):format(path)
end

return {
	"obsidian-nvim/obsidian.nvim",
	lazy = true, -- on-demand loading from .nvim.lua
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"MeanderingProgrammer/render-markdown.nvim", -- for better rendering
		"nvim-telescope/telescope.nvim", -- for pickers
	},
	opts = {
		workspaces = { { name = "notes", path = vim.fn.getcwd } },
		new_notes_location = "notes_subdir",
		notes_subdir = "0-inbox",
		completion = {
			nvim_cmp = false,
			blink = true,
		},
		backlinks = { parse_headers = false },
		wiki_link_func = "prepend_note_path",
		note_frontmatter_func = note_frontmatter_func,
		note_path_func = note_path_func,
		attachments = {
			img_folder = "_assets/attachments",
			img_name_func = img_name_func,
			img_text_func = img_text_func,
			confirm_img_paste = false,
		},
		templates = { folder = "_assets/templates" },
		ui = { enable = false }, -- render-markdown takes care of nice rendering
		-- Get rid of the warning. I can remove it from version 4.
		-- See https://github.com/obsidian-nvim/obsidian.nvim/wiki/Commands
		legacy_commands = false,
	},
	config = function(_, opts)
		require("obsidian").setup(opts)

		vim.api.nvim_create_autocmd("User", {
			desc = "Remove Obisian smart action (<CR>)",
			pattern = "ObsidianNoteEnter",
			callback = function(ev)
				vim.keymap.del("n", "<CR>", { buffer = ev.buf })
			end,
		})

		-- Find operations (with picker)
		vim.keymap.set("n", "<Leader>of", "<Cmd>Obsidian quick_switch<CR>", { desc = "[o]bsidian [f]ind note" })
		vim.keymap.set("n", "<Leader>os", "<Cmd>Obsidian search<CR>", { desc = "[o]bsidian [s]earch" })
		vim.keymap.set("n", "<Leader>ot", "<Cmd>Obsidian tags<CR>", { desc = "[o]bsidian [t]ag" })
		vim.keymap.set("n", "<Leader>ol", "<Cmd>Obsidian links<CR>", { desc = "[o]bsidian [l]inks" })
		vim.keymap.set("n", "<Leader>ob", "<Cmd>Obsidian backlinks<CR>", { desc = "[o]bsidian [b]acklinks" })

		-- Edit operations
		vim.keymap.set("x", "<Leader>ol", "<Cmd>Obsidian link<CR>", { desc = "[o]bsidian add [l]ink" })
		vim.keymap.set("n", "<Leader>op", "<Cmd>Obsidian paste_img <CR>", { desc = "[o]bsidian [p]aste image" })
		vim.keymap.set("n", "<Leader>or", "<Cmd>Obsidian rename<CR>", { desc = "[o]bsidian [r]ename" })
		vim.keymap.set("n", "<Leader>on", "<Cmd>Obsidian new<CR>", { desc = "[o]bsidian new [n]ote" })
		vim.keymap.set("x", "<Leader>on", ":Obsidian extract_note<CR>", { desc = "[o]bsidian extract [n]ote" })
		vim.keymap.set(
			"n",
			"<Leader>oN",
			"<Cmd>Obsidian new_from_template<CR>",
			{ desc = "[o]bsidian new [n]ote from template" }
		)

		vim.api.nvim_create_user_command("ObsidianOpen", open_note, {})
		vim.keymap.set("n", "<Leader>oo", "<Cmd>ObsidianOpen<CR>", { desc = "[o]bsidian [o]pen" })
	end,
}
