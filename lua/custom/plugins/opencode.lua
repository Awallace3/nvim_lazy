return {
  "sudo-tee/opencode.nvim",
  config = function()
    -- Default configuration with all available options
    require('opencode').setup({
      preferred_picker = 'snacks',        -- 'telescope', 'fzf', 'mini.pick', 'snacks', 'select', if nil, it will use the best available picker. Note mini.pick does not support multiple selections
      preferred_completion = 'nvim-cmp',    -- 'blink', 'nvim-cmp','vim_complete' if nil, it will use the best available completion
      default_global_keymaps = true, -- If false, disables all default global keymaps
      default_mode = 'build',        -- 'build' or 'plan' or any custom configured. @see [OpenCode Agents](https://opencode.ai/docs/modes/)
      keymap_prefix = '<leader>o',   -- Default keymap prefix for global keymaps change to your preferred prefix and it will be applied to all keymaps starting with <leader>o
      keymap = {
        editor = {
          ['<leader>og'] = { 'toggle' },                        -- Open opencode. Close if opened
          ['<leader>oi'] = { 'open_input' },                    -- Opens and focuses on input window on insert mode
          ['<leader>oI'] = { 'open_input_new_session' },        -- Opens and focuses on input window on insert mode. Creates a new session
          ['<leader>oo'] = { 'open_output' },                   -- Opens and focuses on output window
          ['<leader>ot'] = { 'toggle_focus' },                  -- Toggle focus between opencode and last window
          ['<leader>oT'] = { 'timeline' },                      -- Display timeline picker to navigate/undo/redo/fork messages
          ['<leader>oq'] = { 'close' },                         -- Close UI windows
          ['<leader>os'] = { 'select_session' },                -- Select and load a opencode session
          ['<leader>oR'] = { 'rename_session' },                -- Rename current session
          ['<leader>op'] = { 'configure_provider' },            -- Quick provider and model switch from predefined list
          ['<leader>oz'] = { 'toggle_zoom' },                   -- Zoom in/out on the Opencode windows
          ['<leader>od'] = { 'diff_open' },                     -- Opens a diff tab of a modified file since the last opencode prompt
          ['<leader>o]'] = { 'diff_next' },                     -- Navigate to next file diff
          ['<leader>o['] = { 'diff_prev' },                     -- Navigate to previous file diff
          ['<leader>oc'] = { 'diff_close' },                    -- Close diff view tab and return to normal editing
          ['<leader>ora'] = { 'diff_revert_all_last_prompt' },  -- Revert all file changes since the last opencode prompt
          ['<leader>ort'] = { 'diff_revert_this_last_prompt' }, -- Revert current file changes since the last opencode prompt
          ['<leader>orA'] = { 'diff_revert_all' },              -- Revert all file changes since the last opencode session
          ['<leader>orT'] = { 'diff_revert_this' },             -- Revert current file changes since the last opencode session
          ['<leader>orr'] = { 'diff_restore_snapshot_file' },   -- Restore a file to a restore point
          ['<leader>orR'] = { 'diff_restore_snapshot_all' },    -- Restore all files to a restore point
          ['<leader>ox'] = { 'swap_position' },                 -- Swap Opencode pane left/right
          ['<leader>opa'] = { 'permission_accept' },            -- Accept permission request once
          ['<leader>opA'] = { 'permission_accept_all' },        -- Accept all (for current tool)
          ['<leader>opd'] = { 'permission_deny' },              -- Deny permission request once
        },
        input_window = {
          ['<cr>'] = { 'submit_input_prompt', mode = { 'n', 'i' } },   -- Submit prompt (normal mode and insert mode)
          ['<esc>'] = { 'close' },                                     -- Close UI windows
          ['<C-c>'] = { 'cancel' },                                    -- Cancel opencode request while it is running
          ['~'] = { 'mention_file', mode = 'i' },                      -- Pick a file and add to context. See File Mentions section
          ['@'] = { 'mention', mode = 'i' },                           -- Insert mention (file/agent)
          ['/'] = { 'slash_commands', mode = 'i' },                    -- Pick a command to run in the input window
          ['#'] = { 'context_items', mode = 'i' },                     -- Manage context items (current file, selection, diagnostics, mentioned files)
          ['<C-i>'] = { 'focus_input', mode = { 'n', 'i' } },          -- Focus on input window and enter insert mode at the end of the input from the output window
          ['<tab>'] = { 'toggle_pane', mode = { 'n', 'i' } },          -- Toggle between input and output panes
          ['<up>'] = { 'prev_prompt_history', mode = { 'n', 'i' } },   -- Navigate to previous prompt in history
          ['<down>'] = { 'next_prompt_history', mode = { 'n', 'i' } }, -- Navigate to next prompt in history
          ['<C-m>'] = { 'switch_mode' },                               -- Switch between modes (build/plan)
        },
        output_window = {
          ['<esc>'] = { 'close' },                            -- Close UI windows
          ['<C-c>'] = { 'cancel' },                           -- Cancel opencode request while it is running
          [']]'] = { 'next_message' },                        -- Navigate to next message in the conversation
          ['[['] = { 'prev_message' },                        -- Navigate to previous message in the conversation
          ['<tab>'] = { 'toggle_pane', mode = { 'n', 'i' } }, -- Toggle between input and output panes
          ['i'] = { 'focus_input', 'n' },                     -- Focus on input window and enter insert mode at the end of the input from the output window
          ['<leader>oS'] = { 'select_child_session' },        -- Select and load a child session
          ['<leader>oD'] = { 'debug_message' },               -- Open raw message in new buffer for debugging
          ['<leader>oO'] = { 'debug_output' },                -- Open raw output in new buffer for debugging
          ['<leader>ods'] = { 'debug_session' },              -- Open raw session in new buffer for debugging
        },
        permission = {
          accept = 'a',     -- Accept permission request once (only available when there is a pending permission request)
          accept_all = 'A', -- Accept all (for current tool) permission request once (only available when there is a pending permission request)
          deny = 'd',       -- Deny permission request once (only available when there is a pending permission request)
        },
        session_picker = {
          rename_session = { '<C-r>' }, -- Rename selected session in the session picker
          delete_session = { '<C-d>' }, -- Delete selected session in the session picker
          new_session = { '<C-n>' },    -- Create and switch to a new session in the session picker
        },
        timeline_picker = {
          undo = { '<C-u>', mode = { 'i', 'n' } }, -- Undo to selected message in timeline picker
          fork = { '<C-f>', mode = { 'i', 'n' } }, -- Fork from selected message in timeline picker
        },
      },
      ui = {
        position = 'right',                                                        -- 'right' (default) or 'left'. Position of the UI split
        input_position = 'bottom',                                                 -- 'bottom' (default) or 'top'. Position of the input window
        window_width = 0.40,                                                       -- Width as percentage of editor width
        zoom_width = 0.8,                                                          -- Zoom width as percentage of editor width
        input_height = 0.15,                                                       -- Input height as percentage of window height
        display_model = true,                                                      -- Display model name on top winbar
        display_context_size = true,                                               -- Display context size in the footer
        display_cost = true,                                                       -- Display cost in the footer
        window_highlight = 'Normal:OpencodeBackground,FloatBorder:OpencodeBorder', -- Highlight group for the opencode window
        icons = {
          preset = 'nerdfonts',                                                    -- 'nerdfonts' | 'text'. Choose UI icon style (default: 'nerdfonts')
          overrides = {},                                                          -- Optional per-key overrides, see section below
        },
        output = {
          tools = {
            show_output = true, -- Show tools output [diffs, cmd output, etc.] (default: true)
          },
          rendering = {
            markdown_debounce_ms = 250, -- Debounce time for markdown rendering on new data (default: 250ms)
            on_data_rendered = nil,     -- Called when new data is rendered; set to false to disable default RenderMarkdown/Markview behavior
          },
        },
        input = {
          text = {
            wrap = true, -- Wraps text inside input window
          },
        },
        completion = {
          file_sources = {
            enabled = true,
            preferred_cli_tool = 'server', -- 'fd','fdfind','rg','git','server' if nil, it will use the best available tool, 'server' uses opencode cli to get file list (works cross platform) and supports folders
            ignore_patterns = {
              '^%.git/',
              '^%.svn/',
              '^%.hg/',
              'node_modules/',
              '%.pyc$',
              '%.o$',
              '%.obj$',
              '%.exe$',
              '%.dll$',
              '%.so$',
              '%.dylib$',
              '%.class$',
              '%.jar$',
              '%.war$',
              '%.ear$',
              'target/',
              'build/',
              'dist/',
              'out/',
              'deps/',
              '%.tmp$',
              '%.temp$',
              '%.log$',
              '%.cache$',
            },
            max_files = 10,
            max_display_length = 50, -- Maximum length for file path display in completion, truncates from left with "..."
          },
        },
      },
      context = {
        enabled = true,    -- Enable automatic context capturing
        cursor_data = {
          enabled = false, -- Include cursor position and line content in the context
        },
        diagnostics = {
          info = false, -- Include diagnostics info in the context (default to false
          warn = true,  -- Include diagnostics warnings in the context
          error = true, -- Include diagnostics errors in the context
        },
        current_file = {
          enabled = true, -- Include current file path and content in the context
        },
        selection = {
          enabled = true, -- Include selected text in the context
        },
      },
      debug = {
        enabled = false,  -- Enable debug messages in the output window
      },
      prompt_guard = nil, -- Optional function that returns boolean to control when prompts can be sent (see Prompt Guard section)
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'markdown', 'opencode_output' },
      },
      ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
    },
    -- Optional, for file mentions and commands completion, pick only one
    'saghen/blink.cmp',
    -- 'hrsh7th/nvim-cmp',

    -- Optional, for file mentions picker, pick only one
    'folke/snacks.nvim',
    -- 'nvim-telescope/telescope.nvim',
    -- 'ibhagwan/fzf-lua',
    -- 'nvim_mini/mini.nvim',
  },
}
-- OG opencode plugin
-- return {
--   'NickvanDyke/opencode.nvim',
--   dependencies = {
--     -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
--     { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
--   },
--   config = function()
--     vim.g.opencode_opts = {
--       -- Your configuration, if any — see `lua/opencode/config.lua`
--       provider = {
--         enabled = "snacks",
--         ---@type opencode.provider.Snacks
--         snacks = {
--           -- Customize `snacks.terminal` to your liking.
--         }
--       }
--     }
--
--     -- Required for `opts.auto_reload`
--     vim.opt.autoread = true
--
--     -- Recommended keymaps
--     vim.keymap.set('n', '<leader>ot', function() require('opencode').toggle() end, { desc = 'Toggle opencode' })
--     vim.keymap.set('n', '<leader>oA', function() require('opencode').ask() end, { desc = 'Ask opencode' })
--     vim.keymap.set('n', '<leader>oa', function() require('opencode').ask('@cursor: ') end,
--       { desc = 'Ask opencode about this' })
--     vim.keymap.set('v', '<leader>oa', function() require('opencode').ask('@selection: ') end,
--       { desc = 'Ask opencode about selection' })
--     vim.keymap.set('n', '<leader>on', function() require('opencode').command('session_new') end,
--       { desc = 'New opencode session' })
--     vim.keymap.set('n', '<leader>oy', function() require('opencode').command('messages_copy') end,
--       { desc = 'Copy last opencode response' })
--     vim.keymap.set('n', '<S-C-u>', function() require('opencode').command('messages_half_page_up') end,
--       { desc = 'Messages half page up' })
--     vim.keymap.set('n', '<S-C-d>', function() require('opencode').command('messages_half_page_down') end,
--       { desc = 'Messages half page down' })
--     vim.keymap.set({ 'n', 'v' }, '<leader>os', function() require('opencode').select() end,
--       { desc = 'Select opencode prompt' })
--
--     -- Example: keymap for custom prompt
--     vim.keymap.set('n', '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end,
--       { desc = 'Explain this code' })
--   end,
-- }
