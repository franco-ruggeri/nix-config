return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")

		-- On macOS, I want to remap <D-w> to <C-w> to have the window functions on <C-w> like on Linux. However:
		-- - Aerospace uses <C-w>, so I can't just remap <D-w> to <C-w> in Karabiner (system level).
		-- - MacOS uses <D-w> for closing windows, so I can't just remap <D-w> to <C-w> in Neovim (application level).
		--
		-- Thus, I use the following trick:
		-- 1. I remap <D-w> to <M-w> in Karabiner (system level).
		-- 2. I remap <M-w> to <C-w> in Neovim (application level).
		if vim.fn.has("macunix") then
			wk.add({
				{ "<M-w>", proxy = "<C-w>", group = "windows" },
			})
		end
	end,
}
