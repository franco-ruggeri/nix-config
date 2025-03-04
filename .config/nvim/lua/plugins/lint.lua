return {
  "mfussenegger/nvim-lint",
  dependencies = {
    "williamboman/mason.nvim",
  },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "pylint", "flake8", "mypy" },
    }

    vim.api.nvim_create_autocmd(
      { "BufReadPost", "BufWritePost" },
      {
        callback = function()
          require("lint").try_lint()
        end,
      }
    )
  end,
}
