return {
  -- "github/copilot.vim",
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  dependencies = {
    -- "zbirenbaum/copilot-cmp",
  },
  config = function()
    require("copilot").setup({
      panel = {
        enabled = true,
        auto_refresh = true,
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
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        trigger_on_accept = true,
        keymap = {
          accept = "<C-F>",
          accept_word = false,
          accept_line = false,
          next = "<M-n]>",
          prev = "<M-n[>",
          dismiss = "<M-]>",
        },
      },
      filetypes = {
        markdown = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if string.match(bufname, '%.ipynb$') then
            print("Copilot enabled for ipynb file")
            return true
          end
          print("Copilot disabled for markdown file")
          return false
        end,
        cpp = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if string.match(bufname, 'leetcode') then
            print("Copilot disabled for leetcode file")
            return false
          end
          return true
        end,
        python = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if string.match(bufname, 'leetcode') then
            print("Copilot disabled for leetcode file")
            return false
          end
          return true
        end,
        rust = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if string.match(bufname, 'leetcode') then
            print("Copilot disabled for leetcode file")
            return false
          end
          return true
        end,
        sh = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          if string.match(vim.fs.basename(bufname), '^%.env.*') then
            -- disable for .env files
            print("Copilot disabled for .env file")
            return false
          end
          return true
        end,
      }
    })
    -- require("copilot_cmp").setup()
    -- local map = vim.keymap.set
    -- map("i", "<C-f>", "copilot#Accept('<CR>')", { noremap = true, silent = true, expr = true, replace_keycodes = false })
    -- map('i', '<M-k>', '<Plug>(copilot-next)')
    -- map('i', '<M-j>', '<Plug>(copilot-previous)')
    -- map('i', '<M-l>', '<Plug>(copilot-select)')
    -- vim.g.copilot_no_tab_map = true
  end
}
