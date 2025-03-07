return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		"williamboman/mason.nvim", -- package manager for LSP servers
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp", -- provides extra capabilities for autocompletion
	},
	config = function()
		local lspconfig = require("lspconfig")
		local mason_lspconfig = require("mason-lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		mason_lspconfig.setup()
		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({ capabilities = capabilities })
			end,
			pylsp = function()
				lspconfig.pylsp.setup({
					capabilities = capabilities,
					settings = {
						pylsp = {
							plugins = {
								pylint = { enabled = true },
								flake8 = { enabled = true },
								black = { enabled = true },
								mypy = { enabled = true },
							},
						},
					},
				})
			end,
		})

		-- When pylsp is installed, install also third-party plugins
		local pylsp = require("mason-registry").get_package("python-lsp-server")
		pylsp:on("install:success", function()
			local command = pylsp:get_install_path() .. "/venv/bin/python"
			local args = {
				"-m",
				"pip",
				"install",
				"-U",
				"python-lsp-black",
				"pylsp-mypy",
			}

			local Job = require("plenary.job")
			---@diagnostic disable: missing-fields
			Job:new({
				command = command,
				args = args,
			}):start()
			---@diagnostic enable: missing-fields
		end)
	end,
}
