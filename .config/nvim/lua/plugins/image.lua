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
}
