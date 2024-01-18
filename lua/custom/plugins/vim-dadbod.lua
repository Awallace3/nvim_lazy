return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod',                     lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true, },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_winwidth = 40
    vim.g.db_win_position = 'right'
    vim.g.db_ui_save_location = '~/data/dbs/vim-dadbod'
    vim.g.db_ui_icons = {
      expanded = {
        db = '▾ ',
        buffers = '▾ ',
        saved_queries = '▾ ',
        schemas = '▾ ',
        schema = '▾ פּ',
        tables = '▾ 藺',
        table = '▾ ',
      },
      collapsed = {
        db = '▸ ',
        buffers = '▸ ',
        saved_queries = '▸ ',
        schemas = '▸ ',
        schema = '▸ פּ',
        tables = '▸ 藺',
        table = '▸ ',
      },
      saved_query = '',
      new_query = '璘',
      tables = '離',
      buffers = '﬘',
      add_connection = '',
      connection_ok = '✓',
      connection_error = '✕',
    }

  end,
  config = function()
    vim.g.db_ui_table_helpers = {
      postgres = {
        primary_key = 'id',
        foreign_key = 'id',
        join_string = ' AS ',
        joiner = ' ON ',
        delete_cascade = ' CASCADE',
        delete_restrict = ' RESTRICT',
        delete_set_null = ' SET NULL',
        delete_set_default = ' SET DEFAULT',
        delete_no_action = ' NO ACTION',
      },
    }
    vim.g.db_ui_table_helpers = {
      sqlite = {
        primary_key = 'id',
        foreign_key = 'id',
        join_string = ' AS ',
        joiner = ' ON ',
        delete_cascade = ' CASCADE',
        delete_restrict = ' RESTRICT',
        delete_set_null = ' SET NULL',
        delete_set_default = ' SET DEFAULT',
        delete_no_action = ' NO ACTION',
      },
    }
    vim.g.db_ui_table_helpers = {
      mysql = {
        primary_key = 'id',
        foreign_key = 'id',
        join_string = ' AS ',
        joiner = ' ON ',
        delete_cascade = ' CASCADE',
        delete_restrict = ' RESTRICT',
        delete_set_null = ' SET NULL',
        delete_set_default = ' SET DEFAULT',
        delete_no_action = ' NO ACTION',
      },
    }
  end,
}
