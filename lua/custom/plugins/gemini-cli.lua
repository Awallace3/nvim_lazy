return {
  "marcinjahn/gemini-cli.nvim",
  cmd = "Gemini",
  -- Example key mappings for common actions:
  keys = {
    { "<leader>gt", "<cmd>Gemini toggle<cr>",   desc = "Toggle Gemini CLI" },
    { "<leader>ga", "<cmd>Gemini ask<cr>",      desc = "Ask Gemini",       mode = { "n", "v" } },
    { "<leader>gj", "<cmd>Gemini add_file<cr>", desc = "Add File" },

  },
  dependencies = {
    "folke/snacks.nvim",
  },
  config = true,
}
