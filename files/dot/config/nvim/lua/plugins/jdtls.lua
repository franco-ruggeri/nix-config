local constants = require("utils").constants
local java_debug = constants.VSCODE_JAVA_DEBUG
	.. "/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin*.jar"
local java_test = constants.VSCODE_JAVA_TEST
	.. "/share/vscode/extensions/vscjava.vscode-java-test/server/com.microsoft.java.test.plugin*.jar"

return {
	"mfussenegger/nvim-jdtls",
	version = false, -- latest commit, otherwise DAP doesn't work
	dependencies = {
		"mfussenegger/nvim-dap", -- for debugging support
	},
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "java",
			callback = function()
				local jdtls = require("jdtls")

				jdtls.start_or_attach({
					cmd = { "jdtls" },
					root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),
					init_options = {
						bundles = { java_debug, java_test },
					},
				})
			end,
		})
	end,
}
