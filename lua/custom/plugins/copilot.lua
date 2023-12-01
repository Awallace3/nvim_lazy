return {
  "github/copilot.vim",
  config = function ()
    
    vim.keymap.set("i", "<M-CR>", 'copilot#Accept("<CR>")', { expr = true })
    vim.keymap.set("i", "<C-f>", 'copilot#Accept("<CR>")', { expr = true })
    vim.keymap.set('i', '<M-k>', '<Plug>(copilot-next)')
    vim.keymap.set('i', '<M-j>', '<Plug>(copilot-previous)')
    vim.g.copilot_filetypes = {
        tex = false,
    }
  end
}
