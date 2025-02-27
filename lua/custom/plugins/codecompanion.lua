return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    -- strategies = {
    --   -- Change the default chat adapter
    --   chat = {
    --     -- adapter = "anthropic",
    --   },
    -- },
    opts = {
      -- Set debug logging
      log_level = "DEBUG",
    },
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "deepseek", -- Give this adapter a different name to differentiate it from the default ollama adapter
            schema = {
              model = {
                default = "deepseek-coder-v2:latest",
              },
              num_ctx = {
                default = 16384,
              },
              num_predict = {
                default = -1,
              },
            },
          })
        end,
        -- ollama = function()
        --   return require("codecompanion.adapters").extend("ollama", {
        --     name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
        --     schema = {
        --       model = {
        --         default = "llama3:latest",
        --       },
        --       num_ctx = {
        --         default = 16384,
        --       },
        --       num_predict = {
        --         default = -1,
        --       },
        --     },
        --   })
        -- end,
      },
    })
  end
}
