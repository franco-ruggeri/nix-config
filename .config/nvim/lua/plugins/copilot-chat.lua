return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "github/copilot.vim",
    -- for curl, log and async functions (see docs)
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  opts = {
    mappings = {
      complete = {
        insert = "", -- disable <Tab> as it conflicts with copilot.vim
      }
    }
  },
}
