return {
  -- "github/copilot.vim",
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  dependencies = {
    "zbirenbaum/copilot-cmp",
  },
  config = function()
    require("copilot").setup({
      panel = {
        enabled = true,
        auto_refresh = false,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<C-f>",
          refresh = "gr",
          open = "<M-CR>"
        },

        layout = {
          position = "bottom", -- | top | left | right | horizontal | vertical
          ratio = 0.4
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        hide_during_completion = true,
        debounce = 75,
        trigger_on_accept = true,
        keymap = {
          accept = "<C-f>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-]>",
        },
      },
    })
    require("copilot_cmp").setup()
    -- local map = vim.keymap.set
    -- map("i", "<C-f>", "copilot#Accept('<CR>')", { noremap = true, silent = true, expr = true, replace_keycodes = false })
    -- map('i', '<M-k>', '<Plug>(copilot-next)')
    -- map('i', '<M-j>', '<Plug>(copilot-previous)')
    -- map('i', '<M-l>', '<Plug>(copilot-select)')
    -- vim.g.copilot_no_tab_map = true
    -- vim.g.copilot_filetypes = {
    --   -- tex = false,
    -- }
  end
}
