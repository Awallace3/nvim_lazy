return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "ravitemer/codecompanion-history.nvim",
    {
      "OXY2DEV/markview.nvim",
      lazy = false,
      opts = {
        preview = {
          filetypes = { "markdown", "codecompanion" },
          ignore_buftypes = {},
          hybrid_modes = {'n'},
          linewise_hybrid_mode = false,
        },
        latex = {
          enable = true,
        },
      },
    },
    {
      "echasnovski/mini.diff",
      config = function()
        local diff = require("mini.diff")
        diff.setup({
          -- Disabled by default
          source = diff.gen_source.none(),
        })
      end,
    },
  },
  config = function()
    require("codecompanion").setup({
      strategies = {
        inline = {
          adapter = "anthropic",
        },
        cmd = {
          adapter = "anthropic",
        },
        chat = {
          adapter = "anthropic",
          tools = {
            ["mcp"] = {
              callback = require("mcphub.extensions.codecompanion"),
              description = "Call tools and resources from the MCP Servers",
              opts = {
                requires_approval = true
              }
            }
          },
          slash_commands = {
            ["git_files"] = {
              description = "List git files",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local handle = io.popen("git ls-files")
                if handle ~= nil then
                  local result = handle:read("*a")
                  handle:close()
                  chat:add_reference({ role = "user", content = result }, "git", "<git_files>")
                else
                  return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = {
                contains_code = false,
              },
            },
            ["git_diff"] = {
              description = "git diff output",
              ---@param chat CodeCompanion.Chat
              callback = function(chat)
                local handle = io.popen("git diff")
                -- print results
                if handle ~= nil then
                  local result = handle:read("*a")
                  print(result)
                  handle:close()
                  chat:add_reference({ role = "user", content = result }, "git", "<git_diff>")
                else
                  return vim.notify("No git diff available", vim.log.levels.INFO, { title = "CodeCompanion" })
                end
              end,
              opts = {
                contains_code = true,
              },
            },

          },
        }
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = os.getenv("ANTHROPIC_API_KEY"),
            },
            schema = {
              model = {
                -- default = "claude-3-7-sonnet-20250219",
                default = "claude-sonnet-4-20250514",
              },
            },
          })
        end,
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
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_vars = true,
              make_slash_commands = true,
              show_result_in_chat = true
            }
          },
          -- history
          history = {
            enabled = true,
            opts = {
              -- Keymap to open history from chat buffer (default: gh)
              keymap = "gh",
              -- Keymap to save the current chat manually (when auto_save is disabled)
              save_chat_keymap = "sc",
              -- Save all chats by default (disable to save only manually using 'sc')
              auto_save = true,
              -- Number of days after which chats are automatically deleted (0 to disable)
              expiration_days = 0,
              -- Picker interface (auto resolved to a valid picker)
              picker = "telescope", --- ("telescope", "snacks", "fzf-lua", or "default")
              -- Customize picker keymaps (optional)
              picker_keymaps = {
                rename = { n = "r", i = "<M-r>" },
                delete = { n = "d", i = "<M-d>" },
                duplicate = { n = "<C-y>", i = "<C-y>" },
              },
              ---Automatically generate titles for new chats
              auto_generate_title = true,
              title_generation_opts = {
                ---Adapter for generating titles (defaults to current chat adapter)
                adapter = nil,               -- "copilot"
                ---Model for generating titles (defaults to current chat model)
                model = nil,                 -- "gpt-4o"
                ---Number of user prompts after which to refresh the title (0 to disable)
                refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
                ---Maximum number of times to refresh the title (default: 3)
                max_refreshes = 3,
              },
              ---On exiting and entering neovim, loads the last chat on opening chat
              continue_last_chat = false,
              ---When chat is cleared with `gx` delete the chat from history
              delete_on_clearing_chat = false,
              ---Directory path to save the chats
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
              ---Enable detailed logging for history extension
              enable_logging = false,
              ---Optional filter function to control which chats are shown when browsing
              chat_filter = nil, -- function(chat_data) return boolean end
            }
          }
        },
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = "Prompt ",                   -- Prompt used for interactive LLM calls
            provider = "default",                 -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
            opts = {
              show_default_actions = true,        -- Show the default actions in the action palette?
              show_default_prompt_library = true, -- Show the default prompt library in the action palette?
            },
          },
        },
      },
    })
    vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    vim.keymap.set({ "n", "v" }, "<M-a>", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
    vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
    -- vim.cmd([[cab cc CodeCompanion]])
  end
}
