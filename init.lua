-- ./lua/custom/plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- [[ Install `lazy.nvim` plugin manager ]]
require('lazy-bootstrap')
require('lazy-plugins')

require('options')
require('keymaps')
require('telescope-setup')
require('treesitter-setup')
require('lsp-setup')
require('cmp-setup')
require("cleanup-options")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
