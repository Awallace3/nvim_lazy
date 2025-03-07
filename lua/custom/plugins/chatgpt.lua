-- Lazy
return -- lazy.nvim
{
  -- "robitx/gp.nvim",
  -- config = function()
  --   -- Attempt to retrieve the GP_CHAT_PATH environment variable
  --   local chat_path = os.getenv("GP_CHAT_PATH") 
  --   -- If GP_CHAT_PATH isn't found, default to $HOME/gp/chats
  --   if not chat_path then
  --     -- Retrieve the HOME environment variable as the fallback
  --     local home_path = os.getenv("HOME")
  --     if not home_path then
  --       -- If HOME isn't found, raise an error or handle it accordingly
  --       error("Neither GP_CHAT_PATH nor HOME environment variables are set.")
  --     else
  --       -- Set the chat directory to the fallback path
  --       chat_path = home_path .. "/gp/chats"
  --     end
  --   else
  --     -- If GP_CHAT_PATH was found, populate it with the appropriate suffix
  --     chat_path = chat_path .. "/gp/chats"
  --   end
  --   -- Use chat_path as the directory for chat operations
  --   local chat_dir = chat_path
  --   require("gp").setup({
  --     -- Please start with minimal config possible.
  --     -- Just openai_api_key if you don't have OPENAI_API_KEY env set up.
  --     -- Defaults change over time to improve things, options might get deprecated.
  --     -- It's better to change only things where the default doesn't fit your needs.
  --
  --     -- required openai api key (string or table with command and arguments)
  --     openai_api_key =  {"gpg",  "--decrypt", vim.fn.expand("$HOME") .. "/secret.txt.gpg"},
  --     -- api endpoint (you can change this to azure endpoint)
  --     -- prefix for all commands
  --     cmd_prefix = "Gp",
  --     curl_params = {},
  --
  --     -- directory for persisting state dynamically changed by user (like model or persona)
  --     state_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/persisted",
  --
  --     -- default command agents (model + persona)
  --     -- name, model and system_prompt are mandatory fields
  --     -- to use agent for chat set chat = true, for command set command = true
  --     -- to remove some default agent completely set it just with the name like:
  --     -- agents = {  { name = "ChatGPT4" }, ... },
  --     agents = {
  --       {
  --         name = "ChatGPT4o",
  --         chat = true,
  --         command = false,
  --         -- string with model name or table with model name and parameters
  --         model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
  --         -- system prompt (use this to specify the persona/role of the AI)
  --         system_prompt = "You are a computational chemistry research AI assistant.\n\n"
  --             .. "The user provided the additional info about how they would like you to respond:\n\n"
  --             .. "- If you're unsure don't guess and say you don't know instead.\n"
  --             .. "- Ask question if you need clarification to provide better answer.\n"
  --             .. "- Think deeply and carefully from first principles step by step.\n"
  --             .. "- Use Socratic method to improve your thinking and coding skills.\n"
  --             .. "- Don't elide any code from your output if the answer requires coding.\n"
  --             .. "- Please create academic responses with citations when relevant, while ensuring that the citations are valid.\n"
  --             ..
  --             "- Output any citations in a bibtex format with the key being 'x:y:z' where x is the first author's last name, y being the year, and z being the first meaningful word of the title with all letters lowercase. Also, please use the journal abbreviated journal name.\n"
  --             .. "- If you cite a paper, please provide all citations at the bottom of the response inside ``` ``` and use the latex \\cite{x:y:z} command to reference the citation in the response.\n"
  --             .. " - For bibtex citations please provide an additional field 'url' with the url of the paper.\n"
  --             -- .. " - When I ask for a latex equation please provide the equation in a latex equation environment with a label of the format eq:x where x is a describibg label for the equation.\n"
  --             -- .. " - If equation terms are defined outside of equation environments, please use dollar signs instead of \\( and \\).\n"
  --       },
  --       {
  --         name = "CodeGPT4",
  --         chat = false,
  --         command = true,
  --         -- string with model name or table with model name and parameters
  --         model = { model = "gpt-4-1106-preview", temperature = 0.8, top_p = 1 },
  --         -- system prompt (use this to specify the persona/role of the AI)
  --         system_prompt = "You are an AI working as a code editor.\n\n"
  --             .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
  --             .. "START AND END YOUR ANSWER WITH:\n\n```",
  --       },
  --     },
  --
  --     -- directory for storing chat files
  --     chat_dir = chat_dir,
  --     -- chat user prompt prefix
  --     chat_user_prefix = "🗨:",
  --     -- chat assistant prompt prefix (static string or a table {static, template})
  --     -- first string has to be static, second string can contain template {{agent}}
  --     -- just a static string is legacy and the [{{agent}}] element is added automatically
  --     -- if you really want just a static string, make it a table with one element { "🤖:" }
  --     chat_assistant_prefix = { "🤖:", "[{{agent}}]" },
  --     -- chat topic generation prompt
  --     chat_topic_gen_prompt = "Summarize the topic of our conversation above"
  --         .. " in two or three words. Respond only with those words.",
  --     -- chat topic model (string with model name or table with model name and parameters)
  --     -- chat_topic_gen_model = "gpt-3.5-turbo-16k",
  --     chat_topic_gen_model = "gpt-4-turbo-preview",
  --     -- explicitly confirm deletion of a chat file
  --     chat_confirm_delete = true,
  --     -- conceal model parameters in chat
  --     chat_conceal_model_params = true,
  --     -- local shortcuts bound to the chat buffer
  --     -- (be careful to choose something which will work across specified modes)
  --     chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
  --     chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
  --     chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
  --     chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },
  --     -- default search term when using :GpChatFinder
  --     chat_finder_pattern = "topic ",
  --     -- if true, finished ChatResponder won't move the cursor to the end of the buffer
  --     chat_free_cursor = false,
  --
  --     -- how to display GpChatToggle or GpContext: popup / split / vsplit / tabnew
  --     toggle_target = "vsplit",
  --
  --     -- styling for chatfinder
  --     -- border can be "single", "double", "rounded", "solid", "shadow", "none"
  --     style_chat_finder_border = "single",
  --     -- margins are number of characters or lines
  --     style_chat_finder_margin_bottom = 8,
  --     style_chat_finder_margin_left = 1,
  --     style_chat_finder_margin_right = 2,
  --     style_chat_finder_margin_top = 2,
  --     -- how wide should the preview be, number between 0.0 and 1.0
  --     style_chat_finder_preview_ratio = 0.5,
  --
  --     -- styling for popup
  --     -- border can be "single", "double", "rounded", "solid", "shadow", "none"
  --     style_popup_border = "single",
  --     -- margins are number of characters or lines
  --     style_popup_margin_bottom = 8,
  --     style_popup_margin_left = 1,
  --     style_popup_margin_right = 2,
  --     style_popup_margin_top = 2,
  --     style_popup_max_width = 160,
  --
  --     -- command config and templates bellow are used by commands like GpRewrite, GpEnew, etc.
  --     -- command prompt prefix for asking user for input (supports {{agent}} template variable)
  --     command_prompt_prefix_template = "🤖 {{agent}} ~ ",
  --     -- auto select command response (easier chaining of commands)
  --     -- if false it also frees up the buffer cursor for further editing elsewhere
  --     command_auto_select_response = true,
  --
  --     -- templates
  --     template_selection = "I have the following from {{filename}}:"
  --         .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
  --     template_rewrite = "I have the following from {{filename}}:"
  --         .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
  --         .. "\n\nRespond exclusively with the snippet that should replace the selection above.",
  --     template_append = "I have the following from {{filename}}:"
  --         .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
  --         .. "\n\nRespond exclusively with the snippet that should be appended after the selection above.",
  --     template_prepend = "I have the following from {{filename}}:"
  --         .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
  --         .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above.",
  --     template_command = "{{command}}",
  --
  --     -- https://platform.openai.com/docs/guides/speech-to-text/quickstart
  --     -- Whisper costs $0.006 / minute (rounded to the nearest second)
  --     -- by eliminating silence and speeding up the tempo of the recording
  --     -- we can reduce the cost by 50% or more and get the results faster
  --     -- directory for storing whisper files
  --     -- whisper_dir = (os.getenv("TMPDIR") or os.getenv("TEMP") or "/tmp") .. "/gp_whisper",
  --     -- multiplier of RMS level dB for threshold used by sox to detect silence vs speech
  --     -- decibels are negative, the recording is normalized to -3dB =>
  --     -- increase this number to pick up more (weaker) sounds as possible speech
  --     -- decrease this number to pick up only louder sounds as possible speech
  --     -- you can disable silence trimming by setting this a very high number (like 1000.0)
  --     -- whisper_silence = "1.75",
  --     -- whisper tempo (1.0 is normal speed)
  --     -- whisper_tempo = "1.75",
  --     -- The language of the input audio, in ISO-639-1 format.
  --     -- whisper_language = "en",
  --
  --     -- to remove some default agent completely set it just with the name like:
  --     -- example hook functions (see Extend functionality section in the README)
  --     hooks = {
  --       InspectPlugin = function(plugin, params)
  --         local bufnr = vim.api.nvim_create_buf(false, true)
  --         local copy = vim.deepcopy(plugin)
  --         local key = copy.config.openai_api_key
  --         copy.config.openai_api_key = key:sub(1, 3) .. string.rep("*", #key - 6) .. key:sub(-3)
  --         local plugin_info = string.format("Plugin structure:\n%s", vim.inspect(copy))
  --         local params_info = string.format("Command params:\n%s", vim.inspect(params))
  --         local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
  --         vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  --         vim.api.nvim_win_set_buf(0, bufnr)
  --       end,
  --
  --       -- GpImplement rewrites the provided selection/range based on comments in it
  --       Implement = function(gp, params)
  --         local template = "Having following from {{filename}}:\n\n"
  --             .. "```{{filetype}}\n{{selection}}\n```\n\n"
  --             .. "Please rewrite this according to the contained instructions."
  --             .. "\n\nRespond exclusively with the snippet that should replace the selection above."
  --
  --         local agent = gp.get_command_agent()
  --         gp.info("Implementing selection with agent: " .. agent.name)
  --
  --         gp.Prompt(
  --           params,
  --           gp.Target.rewrite,
  --           nil, -- command will run directly without any prompting for user input
  --           agent.model,
  --           template,
  --           agent.system_prompt
  --         )
  --       end,
  --
  --       -- your own functions can go here, see README for more examples like
  --       -- :GpExplain, :GpUnitTests.., :GpTranslator etc.
  --
  --       -- -- example of making :%GpChatNew a dedicated command which
  --       -- -- opens new chat with the entire current buffer as a context
  --       -- BufferChatNew = function(gp, _)
  --       -- 	-- call GpChatNew command in range mode on whole buffer
  --       -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
  --       -- end,
  --
  --       -- -- example of adding command which opens new chat dedicated for translation
  --       -- Translator = function(gp, params)
  --       -- 	local agent = gp.get_command_agent()
  --       -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
  --       -- 	gp.cmd.ChatNew(params, agent.model, chat_system_prompt)
  --       -- end,
  --
  --       -- -- example of adding command which writes unit tests for the selected code
  --       -- UnitTests = function(gp, params)
  --       -- 	local template = "I have the following code from {{filename}}:\n\n"
  --       -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
  --       -- 		.. "Please respond by writing table driven unit tests for the code above."
  --       -- 	local agent = gp.get_command_agent()
  --       -- 	gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
  --       -- end,
  --
  --       -- -- example of adding command which explains the selected code
  --       -- Explain = function(gp, params)
  --       -- 	local template = "I have the following code from {{filename}}:\n\n"
  --       -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
  --       -- 		.. "Please respond by explaining the code above."
  --       -- 	local agent = gp.get_chat_agent()
  --       -- 	gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
  --       -- end,
  --     },
  --   })
  --
  --   -- or setup with your own config (see Install > Configuration in Readme)
  --   -- require("gp").setup(config)
  --
  --   -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
  -- end,
}
-- return {
--   "jackMort/ChatGPT.nvim",
--   event = "VeryLazy",
--   config = function()
--     require("chatgpt").setup({
--       api_key_cmd = "gpg --decrypt " .. vim.fn.expand("$HOME") .. "/secret.txt.gpg",
--       yank_register = "+",
--       edit_with_instructions = {
--         diff = true,
--         keymaps = {
--           close = "<C-c>",
--           accept = "<C-y>",
--           toggle_diff = "<C-d>",
--           toggle_settings = "<C-o>",
--           cycle_windows = "<Tab>",
--           use_output_as_input = "<C-i>",
--         },
--       },
--       chat = {
--         welcome_message = "Welcome to ChatGPT! Type <C-d> to start a new message.",
--         loading_text = "Loading, please wait ...",
--         question_sign = "",
--         answer_sign = "ﮧ",
--         max_line_length = 80,
--         sessions_window = {
--           border = {
--             style = "rounded",
--             text = {
--               top = " Sessions ",
--             },
--           },
--           win_options = {
--             winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
--           },
--         },
--         keymaps = {
--           close = "<C-c>",
--           yank_last = "<C-y>",
--           yank_last_code = "<C-k>",
--           scroll_up = "<C-u>",
--           scroll_down = "<C-d>",
--           new_session = "<C-n>",
--           cycle_windows = "<Tab>",
--           cycle_modes = "<C-f>",
--           select_session = "<C-e>",
--           rename_session = "r",
--           delete_session = "d",
--           draft_message = "<C-d>",
--           toggle_settings = "<C-o>",
--           toggle_message_role = "<C-r>",
--           toggle_system_role_open = "<C-s>",
--           stop_generating = "<C-x>",
--         },
--       },
--       popup_layout = {
--         default = "center",
--         center = {
--           width = "80%",
--           height = "80%",
--         },
--         right = {
--           width = "30%",
--           width_settings_open = "50%",
--         },
--       },
--       popup_window = {
--         border = {
--           highlight = "FloatBorder",
--           style = "rounded",
--           text = {
--             top = " ChatGPT ",
--           },
--         },
--         win_options = {
--           wrap = true,
--           linebreak = true,
--           foldcolumn = "1",
--           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
--         },
--         buf_options = {
--           filetype = "markdown",
--         },
--       },
--       system_window = {
--         border = {
--           highlight = "FloatBorder",
--           style = "rounded",
--           text = {
--             top = " SYSTEM ",
--           },
--         },
--         win_options = {
--           wrap = true,
--           linebreak = true,
--           foldcolumn = "2",
--           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
--         },
--       },
--       popup_input = {
--         prompt = "  ",
--         border = {
--           highlight = "FloatBorder",
--           style = "rounded",
--           text = {
--             top_align = "center",
--             top = " Prompt ",
--           },
--         },
--         win_options = {
--           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
--         },
--         submit = "<C-Enter>",
--         submit_n = "<Enter>",
--         max_visible_lines = 20
--       },
--       settings_window = {
--         border = {
--           style = "rounded",
--           text = {
--             top = " Settings ",
--           },
--         },
--         win_options = {
--           winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
--         },
--       },
--       openai_params = {
--         model = "gpt-4",
--         frequency_penalty = 0,
--         presence_penalty = 0,
--         max_tokens = 8192 / 2,
--         temperature = 0,
--         top_p = 1,
--         n = 1,
--       },
--       openai_edit_params = {
--         model = "code-davinci-edit-001",
--         temperature = 0,
--         top_p = 1,
--         n = 1,
--       },
--       show_quickfixes_cmd = "Trouble quickfix",
--       predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
--     })
--   end,
--   dependencies = {
--     "MunifTanjim/nui.nvim",
--     "nvim-lua/plenary.nvim",
--     "nvim-telescope/telescope.nvim"
--   }
-- }
