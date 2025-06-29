return {
	"iamcco/markdown-preview.nvim",
	build = ":call mkdp#util#install()",
	ft = { "markdown" },
	init = function()
		-- Since I mainly use Neovim over SSH...
		vim.cmd([[
      function Noop(url)
      " Do nothing
      endfunction
    ]])
		vim.g.mkdp_browserfunc = "Noop" -- ... disable browser opening
		vim.g.mkdp_port = 5050 -- ... use always the same port (easier to forward)
		vim.g.mkdp_echo_preview_url = 1 -- ... print the URL (to confirm which port is used)
	end,
	config = function()
		vim.keymap.set("n", "<leader>mp", "<Cmd>MarkdownPreviewToggle<CR>", { desc = "[m]arkdown [p]review toggle" })
	end,
}
