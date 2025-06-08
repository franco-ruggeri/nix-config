return {
	"iamcco/markdown-preview.nvim",
	build = ":call mkdp#util#install()",
	ft = { "markdown" },
	init = function()
		-- In SSH sessions, port forwarding can be used to access the preview.
		-- For this use case, we need to...
		vim.g.mkdp_port = 5000 -- ... use a predefined port
		vim.g.mkdp_open_to_the_world = 1 -- ... make the server listen on all interfaces
		vim.g.mkdp_echo_preview_url = 1 -- ... print the URL
	end,
	config = function()
		vim.cmd([[
    function Noop(url)
    " Do nothing
    endfunction
    ]])

		vim.keymap.set("n", "<leader>mp", function()
			vim.g.mkdp_browserfunc = "Noop" -- in SSH sessions, we do not want to open the browser on the server
			vim.cmd("MarkdownPreview")
		end, { desc = "[m]arkdown [p]review start" })
		vim.keymap.set("n", "<leader>mP", "<Cmd>MarkdownPreviewStop<CR>", { desc = "[m]arkdown [p]review stop" })
	end,
}
