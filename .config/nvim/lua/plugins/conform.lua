return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  dependencies = {
    "williamboman/mason.nvim",
  },
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      python = { "black" },
    },
    format_on_save = {
      lsp_format = "fallback",
      timeout_ms = 500,
    },
  },
}
