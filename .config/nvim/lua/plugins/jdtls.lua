return {
	"mfussenegger/nvim-jdtls",
	version = false, -- latest commit, otherwise DAP doesn't work
	dependencies = {
		"williamboman/mason.nvim", -- package manager for installing jdtls
		"mfussenegger/nvim-dap", -- for debugging support
	},
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				local jdtls = require("jdtls")
				local mason_registry = require("mason-registry")
				local bundles = {}

				if not mason_registry.is_installed("jdtls") then
					return
				end

				if mason_registry.is_installed("java-debug-adapter") then
					bundles:insert(
						vim.fn.glob(
							vim.env.MASON
								.. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin*.jar"
						)
					)
				end

				if mason_registry.is_installed("java-test") then
					bundles:insert(
						vim.fn.glob(
							vim.env.MASON .. "/packages/java-test/extension/server/com.microsoft.java.test.plugin*.jar"
						)
					)
				end

				jdtls.start_or_attach({
					cmd = { vim.env.MASON .. "/packages/jdtls/bin/jdtls" },
					root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
					init_options = { bundles = bundles },
				})
			end,
		})
	end,
}
