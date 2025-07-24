local backends = {
	"kitty", -- high-fidelity, not working in nested tmux and dev containers
	"ueberzug", -- low-fidelity, working everywhere
}
local backend_idx = 1

return {
	"3rd/image.nvim",
	version = false,
	build = false,
	opts = {
		backend = backends[backend_idx],
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

		local function change_backend()
			backend_idx = (backend_idx % #backends) + 1
			opts.backend = backends[backend_idx]
			image.clear()
			image.setup(opts)
		end
		vim.api.nvim_create_user_command("ImageBackendChange", change_backend, {})
	end,
}
