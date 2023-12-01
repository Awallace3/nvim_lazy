return {
  "github/copilot.vim",
  config = function ()
    local map = vim.keymap.set
    map("i", "<C-f>", "copilot#Accept('<CR>')", {noremap = true, silent = true, expr=true, replace_keycodes = false })
    map("i", "<M-CR>", 'copilot#Accept("<CR>")', {noremap = true, silent = true, expr=true, replace_keycodes = false })
    map('i', '<M-k>', '<Plug>(copilot-next)')
    map('i', '<M-j>', '<Plug>(copilot-previous)')
    map('i', '<M-l>', '<Plug>(copilot-select)')

    vim.g.copilot_filetypes = {
        tex = false,
    }
  end
}
