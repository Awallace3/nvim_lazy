-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
local snippets_folder = os.getenv("XDG_CONFIG_HOME") .. "/nvim/snippets/"
-- require("luasnip.loaders.from_snipmate").lazy_load({ paths = snippets_folder })
require("luasnip.loaders.from_snipmate").lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-y>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      -- if cmp.visible() then
      --   cmp.select_next_item()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      -- if cmp.visible() then
      --   cmp.select_prev_item()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    -- per_filetype = {
    --   codecompanion = { "codecompanion" },
    -- },
    -- { name = "copilot",  group_index = 2 },
    { name = 'nvim_lsp', group_index = 2 },
    { name = 'luasnip',  group_index = 2 },
    { name = "vimtex",   group_index = 2 },
    -- { name = "nvim_lsp_signature_help" },
    { name = "path",     group_index = 2 },
  },
}

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})

cmp.setup.filetype({ 'tex', 'plaintex' }, {
  completion = {
    -- Vim regex: treat ":" as part of a keyword token
    keyword_pattern = [[\%(\k\|:\)\+]],
  },
})

-- vim: ts=2 sts=2 sw=2 et
