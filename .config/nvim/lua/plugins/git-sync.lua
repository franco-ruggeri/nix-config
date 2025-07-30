local function confirm()
	local response = vim.fn.input("Are you sure you want to enable set up git-sync? [Y/n]: ")

	vim.notify("\n")
	if response:lower() == "y" then
		vim.notify("gyt-sync set up confirmed", vim.log.levels.INFO)
	else
		vim.notify("git-sync setup cancelled", vim.log.levels.INFO)
	end
end

return {
	"luispflamminger/git-sync.nvim",
	lazy = true, -- on-demand loading from .nvim.lua
	opts = {
		repos = {
			{
				path = vim.fn.getcwd(),
				sync_interval = 1,
				auto_pull = true,
				auto_push = true,
				commit_template = "[{hostname}] vault sync: {timestamp}",
			},
		},
		-- This plugin automatically pushes to remote repos. I don't want to risk
		-- enabling it by mistake. Thus, I add this confirmation option. When true,
		-- it will prompt for confirmation before setting up the plugin.
		confirm = true,
	},
	config = function(_, opts)
		if opts.confirm and not confirm() then
			return
		end
		require("git-sync").setup(opts)
	end,
}
