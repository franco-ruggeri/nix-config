return {
	"iamcco/markdown-preview.nvim",
	build = ":call mkdp#util#install()",
	ft = { "markdown" },
	init = function()
		-- In SSH sessions, port forwarding can be used to access the preview.
		-- We need to print the URL and make the server listen on all interfaces.
		vim.g.mkdp_echo_preview_url = 1
		vim.g.mkdp_open_to_the_world = 1
	end,
	config = function()
		vim.cmd([[
    function Noop(url)
    " Do nothing
    endfunction
    ]])

		vim.keymap.set("n", "<leader>mp", function()
			vim.g.mkdp_browserfunc = ""
			vim.cmd("MarkdownPreviewToggle")
		end, { desc = "[m]arkdown [p]review toggle (with browser)" })

		-- In SSH sessions, we might not want to open the browser.
		vim.keymap.set("n", "<leader>mP", function()
			vim.g.mkdp_browserfunc = "Noop"
			vim.cmd("MarkdownPreviewToggle")
		end, { desc = "[m]arkdown [p]review toggle (without browser)" })
	end,
}
