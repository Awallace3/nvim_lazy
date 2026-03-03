return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-python",
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
  },
  lazy = true,
  init = function()
    local nt = require("neotest")
    local cwd = vim.fn.getcwd()
    local is_psi4 = vim.fn.fnamemodify(cwd, ":t") == "psi4"

    nt.setup({
      adapters = {
        require("neotest-python")({
          -- dap = { justMyCode = true, },
          args = { "--log-level", "DEBUG" },
          runner = "pytest",
        })
      },
      discovery = {
        concurrent = 1,
        enabled = true,
        filter_dir = function(_, rel_path)
          if not is_psi4 then
            return true
          end

          return rel_path == "tests" or rel_path:match("^tests/pytest") ~= nil
        end,
      },
      floating = {
        border = "rounded",
        max_height = 0.9,
        max_width = 0.8,
        options = {}
      },
      icons = {
        passed = "",
        running = "",
        failed = "",
        unknown = "",
      },
      quickfix = { open = false },
      output = { open_on_run = false },
      lazy = true,
    })
    nt.state.adapter_ids()
    local keymap = vim.api.nvim_set_keymap
    local opts = { noremap = true }
    keymap('n', '[j', '<CMD>lua require("neotest").jump.next({status = "failed"})<CR>', opts)
    keymap('n', ']j', '<CMD>lua require("neotest").jump.prev({status = "failed"})<CR>', opts)
  end,
}
