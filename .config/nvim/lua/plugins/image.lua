-- TODO: test it over SSH and in nested tmux sessions
return {
	"3rd/image.nvim",
	version = false,
	build = false,
	opts = {
		processor = "magick_cli",
		tmux_show_only_in_active_window = true,
		integrations = {
			-- TODO: can I render only when the cursor is NOT on the image? consistent with render-markdown
			markdown = {
				clear_in_insert_mode = true,
			},
		},
	},
}
