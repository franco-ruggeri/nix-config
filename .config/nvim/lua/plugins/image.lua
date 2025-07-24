return {
	"3rd/image.nvim",
	version = false,
	build = false,
	opts = {
		processor = "magick_cli",
		tmux_show_only_in_active_window = true,
		integrations = {
			markdown = {
				only_render_image_at_cursor = true,
			},
		},
	},
	config = function(_, opts)
		local image = require("image")
		image.setup(opts)

		local enabled = true
		local function toggle_markdown()
			enabled = not enabled
			if enabled then
				opts.integrations.markdown.filetypes = { "markdown", "md" }
			else
				-- Disable markdown integration by the removing the filetypes associated with it.
				--
				-- Note that setting opts.integrations.markdown.enabled=false does not work.
				-- That flag is used for loading the integration and cannot be undone dynamically.
				opts.integrations.markdown.filetypes = {}
			end
			image.setup(opts)
		end

		vim.api.nvim_create_user_command("MarkdownImageToggle", toggle_markdown, {})
		vim.keymap.set("n", "<leader>mi", "<Cmd>MarkdownImageToggle<CR>", { desc = "[m]arkdown [i]mage toggle" })
	end,
}
