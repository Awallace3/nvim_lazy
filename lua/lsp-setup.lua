-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

 function YankCodeBlock()
     local ts_utils = require'nvim-treesitter.ts_utils'
     local parser = vim.treesitter.get_parser(0, "markdown")
     local tree = parser:parse()[1]
     local root = tree:root()

     local node = ts_utils.get_node_at_cursor()
     if node == nil then
         print("No node at cursor position")
         return
     end

     while node do
         -- Check if the node is a fenced_code_block (depends on the parser grammar)  
         local node_type = node:type()
         if node_type == 'fence_block' or node_type == 'code_block' then
             local start_row, start_col, end_row, end_col = node:range()

             -- Select the code block
             vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
             vim.cmd('normal! v')

             local end_position = vim.api.nvim_buf_line_count(0) == end_row and end_col or end_col + 1
             vim.api.nvim_win_set_cursor(0, {end_row + 1, end_position})
             vim.cmd('normal! y')
             print("Code block yanked")
             return
         end
         node = node:parent()  -- Move to the parent node
     end

     print("No code block found")
 end

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local lspconfig = require('lspconfig')


-- document existing key chains

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local function collect_words()
  local nvim_config_spell = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
  local words = {}
  for line in io.lines(nvim_config_spell) do
    table.insert(words, line)
  end
  return words
end

Words = collect_words()

local servers = {
  clangd = {},
  rust_analyzer = {},
  julials = {},
  ltex = {},
  texlab = {},
  yamlls = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
  jedi_language_server = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

local formatters = {
  black = {},
  stylua = {},
  clang_format = {},
}

local ensure_installed = vim.tbl_keys(servers)

mason_lspconfig.setup {
  ensure_installed = ensure_installed,
}

MainPythonFile = "main.py"
UpdateMainPython = function()
  -- get active buffer's file path and name and update global variable MainPythonFile
  MainPythonFile = vim.fn.expand("%:t")
  print("Main Python File Updated to: " .. MainPythonFile)
end

RunMainPython = function()
  print("Running Main Python File: " .. MainPythonFile)
  -- split widnow and run python file

  vim.cmd("vs")
  -- move to right buffer
  vim.cmd("wincmd l")
  -- run python file
  vim.cmd("term python " .. MainPythonFile)
end

MainbashFile = "run.sh"
UpdateMainbash = function()
  -- get active buffer's file path and name and update global variable MainbashFile
  MainbashFile = vim.fn.expand("%:t")
  print("Main bash File Updated to: " .. MainbashFile)
end

RunMainbash = function()
  print("Running Main bash File: " .. MainbashFile)
  -- split widnow and run bash file

  vim.cmd("vs")
  -- move to right buffer
  vim.cmd("wincmd l")
  -- run bash file
  vim.cmd("term bash " .. MainbashFile)
end


-- conda_env_path = vim.fn.expand("~/miniconda3/envs/p4dev18/bin")
-- get $CONDA_PREFIX/bin path
conda_prefix_path = vim.fn.expand("$CONDA_PREFIX/bin")
-- check if os is APPLE or LINUX
local conda_cpp = ""
local function get_os()
  local uname = vim.loop.os_uname()
  if uname.sysname == "Darwin" then
    return "APPLE"
  elseif uname.sysname == "Linux" then
    return "LINUX"
  else
    return "UNKNOWN"
  end
end

Os_type = get_os()
if Os_type == "APPLE" then
  conda_cpp = conda_prefix_path .. "/x86_64-apple-darwin13.4.0-clang++"
elseif Os_type == "LINUX" then
  conda_cpp = conda_prefix_path .. "/x86_64-conda-linux-gnu-c++"
else
  conda_cpp = conda_prefix_path .. "/x86_64-conda-linux-gnu-c++"
end

UserHome = vim.fn.expand("$HOME")

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
  ["lua_ls"] = function()
    lspconfig.lua_ls.setup {
      capabilities = capabilities,
      settings = {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
            -- Setup your lua path
            path = vim.split(package.path, ';')
          },
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = { 'vim' }
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
            }
          }
        }
      }
    }
  end,
  ["rust_analyzer"] = function()
    lspconfig.rust_analyzer.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          imports = {
            granularity = {
              group = "module",
            },
            prefix = "self",
          },
          cargo = {
            buildScripts = {
              enable = true,
            },
          },
          procMacro = {
            enable = true
          },
        }
      }
    }
  end,
  ["julials"] = function()
    lspconfig.julials.setup {
      on_new_config = function(new_config, _)
        local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
        -- local julia = vim.fn.expand("~/gits/julia/julia")
        local sysimage_arg = "--sysimage=" ..
            vim.fn.expand("~/.julia/environments/nvim-lspconfig/languageserver.so")
        local sysimage_native = "--sysimage-native-code=yes"
        if false then
          new_config.cmd[5] = (new_config.cmd[5]):gsub("using LanguageServer",
            "using Revise; using LanguageServer; if isdefined(LanguageServer, :USE_REVISE); LanguageServer.USE_REVISE[] = true; end")
        elseif require 'lspconfig'.util.path.is_file(julia) then
          vim.notify("Julia LSP Engaged!")
          new_config.cmd[1] = julia
          if new_config.cmd[2] ~= sysimage_arg then
            table.insert(new_config.cmd, 2, sysimage_arg)
            table.insert(new_config.cmd, 3, sysimage_native)
          end
        end
      end,
      -- This just adds dirname(fname) as a fallback (see nvim-lspconfig#1768).
      root_dir = function(fname)
        local util = require 'lspconfig.util'
        return util.root_pattern 'Project.toml' (fname) or util.find_git_ancestor(fname) or
            util.path.dirname(fname)
      end,
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,
  ['texlab'] = function()
    lspconfig.texlab.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        texlab = {
          rootDirectory = nil,
          build = {
            executable = 'latexmk',
            args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
            onSave = false,
            forwardSearchAfter = false,
          },
          auxDirectory = '.',
          forwardSearch = {
            executable = nil,
            args = {},
          },
          chktex = {
            onOpenAndSave = false,
            onEdit = false,
          },
          diagnosticsDelay = 300,
          latexFormatter = 'latexindent',
          -- latexindent = {
          --   extra_args = { "-l", vim.fn.expand("$HOME/.indentconfig.yaml"), "-m" },
          --   -- lua get from $HOME/latexindent.yaml
          --   -- ['local'] = vim.fn.expand("$HOME/latexindent.yaml"),
          --   -- ['local'] = UserHome .. "/latexindent.yaml",
          -- },
          -- bibtexFormatter = 'texlab',
          -- formatterLineLength = 30,
        },
      },
    }
  end,
}

lspconfig.ltex.setup {
  enabled = {
    "latex", "tex", "bib",
    -- "markdown",
  },
  on_attach = on_attach,
  capabilities = capabilities,
  checkFrequency = "save",
  language = "en-US",
  settings = {
    ltex = {
      dictionary = {
        ["en-US"] = Words,
      },
      disabledRules = {
        ['en-US'] = {
          "ARROWS",
          "WHITESPACE",
          "UNPAIRED",
          "SENTENCE_WHITESPACE",
        },
      },
      additionalRules = {
        ignorePatterns = {
          -- camelCasePattern
          "([a-z]+[A-Z]+[a-z]+)+",
          -- word containing a number
          "[a-zA-Z]*[0-9]+[a-zA-Z]*",
        }
      },
      markdown = {
        nodes = {
          CodeBlock = "ignore",
          FencedCodeBlock = "ignore",
          AutoLink = "ignore",
          Link = "ignore",
          LinkNode = "ignore",
          LinkRef = "ignore",
          Code = "dummy",
        }
      }
    },
  },
}


lspconfig.clangd.setup {
  cmd = {
    "clangd",
    "--log=verbose",
    "--compile-commands-dir=./build",
    -- "--query-driver=/usr/bin/g++",
    -- "--query-driver=/usr/bin/g++,/theoryfs2/ds/amwalla3/miniconda3/envs/p4dev18/bin/x86_64-conda-linux-gnu-c++",
    "--query-driver=/usr/bin/g++," .. conda_cpp,
  },
  capabilities = capabilities
}

require('which-key').register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'More git', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
}

local wk = require("which-key")
wk.setup {
  plugins = {
    marks = true,
    registers = true,
    spelling = { enabled = false, suggestions = 20 },
    presets = {
      operators = false,
      motions = false,
      text_objects = false,
      windows = false,
      nav = false,
      z = false,
      g = false
    }
  }
}

-- Terminal = require('toggleterm.terminal').Terminal
-- local toggle_float = function()
--   local float = Terminal:new({ direction = "float" })
--   return float:toggle()
-- end
-- local toggle_top = function()
--   local top = Terminal:new({ cmd = 'top', direction = "float" })
--   return top:toggle()
-- end

GetPythonFunctionName = function()
  local function_name = vim.fn.search("def", "bnW")
  if function_name == 0 then
    print("No Function")
    return nil
  else
    local val = vim.fn.getline(function_name):match("def%s+(.-)%s*%(")
    print(val)
    return val
  end
end

local PytestPythonFunction = function()
  local function_name = GetPythonFunctionName()
  print(function_name)
  local fname = vim.fn.expand("%:t")
  if function_name == nil then
    return print("No Function Name found for pytest!")
  end
  local cmd = "vs"
  vim.cmd(cmd)
  cmd = "term pytest " .. fname .. " -k '" .. function_name .. "'"
  print(cmd)
  vim.cmd(cmd)
  print("R:" .. function_name)
end


GetPath = function(str, sep)
  sep = sep or '/'
  return str:match("(.*" .. sep .. ")")
end
-- get directory of python3_host_prog path
local nvim_mason_bin = "silent !" .. "~/.local/share/nvim/mason/bin/"

Formatter = function()
  local filetype = vim.bo.filetype
  -- if filetype == "python" then
  --   vim.cmd("write")
  --   local cmd = nvim_mason_bin .. "black --quiet" .. " " .. vim.fn.expand("%:p")
  --   vim.cmd(cmd)
  --   vim.cmd("e!")
  if filetype == "htmldjango" or filetype == "html" then
    vim.cmd("write")
    local cmd = nvim_mason_bin .. "djlint" .. " --reformat --indent 4 " .. vim.fn.expand("%:p")
    print(cmd)
    vim.cmd(cmd)
    vim.cmd("e!")
  elseif filetype == "css" then
    vim.cmd("write")
    local cmd = nvim_mason_bin .. "stylelint" .. " --fix " .. vim.fn.expand("%:p")
    print(cmd)
    vim.cmd(cmd)
    vim.cmd("e!")
  elseif filetype == "sql" then
    vim.cmd("write")
    local cmd = nvim_mason_bin .. "sql-formatter" .. " --language postgresql " .. vim.fn.expand("%:p")
    print(cmd)
    vim.cmd(cmd)
    vim.cmd("e!")
  elseif filetype == "lua" or filetype == "tex" or filetype == "julia" then
    vim.lsp.buf.format({ timeout_ms = 10000 })
  else
    vim.lsp.buf.format({ timeout_ms = 5000 })
  end
end

local find_files_different_root = function()
  require("telescope.builtin").find_files({ cwd = vim.fn.expand("%:p:h") })
end

local grep_files_different_root = function()
  require("telescope.builtin").live_grep({ cwd = vim.fn.expand("%:p:h") })
end
-- Neogit =  require("neogit")
--
local function get_filetype()
  local filetype = vim.bo.filetype
  print(filetype)
  return filetype
end

-- require("telescope").load_extension('harpoon')
-- local function harpoon_nav_file()
--     local ind = tonumber(vim.fn.input("Harpoon Index: "))
--     require("harpoon.ui").nav_file(ind)
-- end

function Round_number()
  local precision = vim.fn.input("Precision: ", "")
  local str_cmd = "'<,'>s/\\d\\+\\.\\d\\+/\\=printf('%." .. precision .. "f', str2float(submatch(0)))/g"
  print(str_cmd)
  vim.cmd(str_cmd)
  vim.api.nvim_input("<esc>")
end

function initJypterSession()
  local file_extension = vim.fn.expand("%:e")
  local conda_env = os.getenv("CONDA_PREFIX")
  print(conda_env)
  if file_extension ~= 'ipynb' and file_extension ~= 'py' then
    print(file_extension)
    print("Not a Jupyter Notebook")
    return
  end
  if file_extension == 'ipynb' then
    vim.cmd(':call jukit#convert#notebook_convert("jupyter-notebook")')
  end
  local cmd = "JukitOut conda activate " .. conda_env
  print(cmd)
  vim.cmd(cmd)
end

local nvim_config_path = os.getenv("XDG_CONFIG_HOME") .. "/nvim"

local insert_mappings = {
  ["<C-k>"] = {'<cmd>lua vim.lsp.buf.hover()<cr>', 'Hover Commands'}
}
local insert_opts = { mode = "i" }
wk.register(insert_mappings, insert_opts)

local normal_mappings = {
  q = { ":bn<bar>bd #<CR>", "Close Buffer" },
  Q = { ":wq<cr>", "Save & Quit" },
  x = { ":bdelete<cr>", "Close" },
  d = {
    name = "Database",
    u = { "<Cmd>DBUIToggle<Cr>", "Toggle UI" },
    f = { "<Cmd>DBUIFindBuffer<Cr>", "Find buffer" },
    r = { "<Cmd>DBUIRenameBuffer<Cr>", "Rename buffer" },
    q = { "<Cmd>DBUILastQueryInfo<Cr>", "Last query info" },
  },
  e = {
    name = "Edit Config",
    E = { ":vs<bar>e " .. nvim_config_path .. "/init.lua<cr>", "Edit config" },
    e = { ":e " .. nvim_config_path .. "/init.lua<cr>", "Edit config" },
    O = { ":vs<bar>e " .. nvim_config_path .. "/lua/options.lua<cr>", "Edit Options" },
    o = { ":e " .. nvim_config_path .. "/lua/options.lua<cr>", "Edit Options" },
    c = { ":e " .. nvim_config_path .. "/lua/chatgpt-config.lua<cr>", "Edit config" },
    W = {
      ":vs<bar>e " .. nvim_config_path .. "/lua/whichkey-config/init.lua<cr>",
      "Edit config"
    },
    p = {
      ":e " .. nvim_config_path .. "/lua/custom/plugins<cr>",
      "Edit Plugins"
    },
    P = {
      ":vs<bar>e " .. nvim_config_path .. "/lua/custom/plugins<cr>",
      "Edit Plugins"
    },
    s = { ":e " .. nvim_config_path .. "/snippets<cr>", "Edit config" },
    S = {
      ":vs<bar>e " .. nvim_config_path .. "/lua/luasnip-config.lua<bar>40<cr>",
      "Edit Snippets"
    },
    l = {
      ":e " .. nvim_config_path .. "/lua/lsp-setup.lua<cr>",
      "Edit lsp"
    },
    L = {
      ":vs<bar>e " .. nvim_config_path .. "/lua/lsp-setup.lua<cr>",
      "Edit lsp (split)"
    },
    m = {
      ":e " .. nvim_config_path .. "/lua/cmp-setup.lua<cr>",
      "Edit cmp"
    },
    M = {
      ":vs<bar>e " .. nvim_config_path .. "/lua/cmp-setup.lua<cr>",
      "Edit cmp (split)"
    },
    f = { ":e " .. nvim_config_path .. "/nvim_simplified<cr>", "Edit Last" },
    -- S = {":vs<bar>e ~/.config/nvim/snippets<cr>", "Edit config"}
  },
  F = { Formatter, "Format Buffer" },
  g = {
    -- gitgutter
    name = "Git",
    d = { ":Git difftool<cr>", "Git Diff" },
    -- n = { ":GitGutterNextHunk<cr>", "Next Hunk" },
    -- p = { ":GitGutterPrevHunk<cr>", "Prev Hunk" },
    -- a = { ":GitGutterStageHunk<cr>", "Stage Hunk" },
    -- u = { ":GitGutterUndoHunk<cr>", "Undo Hunk" },
    -- vimaget
    -- s = {":Magit<cr>", "Git Status"},
    s = { ":lua require('neogit').open()<CR>", "Git Status" },
    S = { ":lua require('neogit').open({ cwd = vim.fn.expand('%:p:h')})<CR>", "Git Status" },
    -- t = {":lua require('neogit')", "Git Status"},
    -- fugitive
    P = { ":Git push<cr>", "Git Push" },
    b = { ":Git blame<cr>", "Git Blame" },
    c = { ":Git commit<bar>:startinsert<cr>", "Git Commit" },
    af = { ":Gw<cr>", "Add File" }
  },
  i = {
    name = "Insert",
    -- t = {'o* [○] ', "Insert Task"},
    t = { 'o* [ ] ', "Insert Task" },
  },
  -- h = {
  --     name = "Harpoon",
  --     i = { harpoon_nav_file, "Harpoon Index" },
  --     n = { ':lua require("harpoon.ui").nav_next()<cr>', "Harpoon Next" },
  --     p = { ':lua require("harpoon.ui").nav_prev()<cr>', "Harpoon Previous" },
  --
  -- },
  f = {
    name = "Find",
    a = { ':lua require("harpoon.mark").add_file()<cr>', "Harpoon Add" },
    m = { ':lua require("harpoon.ui").toggle_quick_menu()<cr>', "Harpoon Menu" },
    f = { ":Telescope find_files<cr>", "Telescope Find Files" },
    r = { ":Telescope live_grep<cr>", "Telescope Live Grep" },
    F = { find_files_different_root, "Telescope Find Files" },
    R = { grep_files_different_root, "Telescope Live Grep" },
    b = { ":Telescope buffers<cr>", "Telescope Buffers" },
    h = { ':Telescope harpoon marks<cr>', "Telescope Harpoon" },
    d = { ":Telescope help_tags<cr>", "Telescope Help Tags" },
    -- p = { ":redir @+ | echo expand('%:p') | redir END<CR>", "Current File Path" },
    p = { ":echo expand('%:p')<CR>", "Current File Path" },
    t = { get_filetype, "Current File Path" },
    -- i = { harpoon_nav_file, "Harpoon Index" },
  },
  -- n = { ":Neotree toggle<cr>", "Neotree Toggle" },
  -- n = { ":Lexplore<cr>", "Lexplore Toggle" },
  -- n = { ":NvimTreeToggle<cr>", "Tree Toggle" },
  n = { "<cmd>30vs<bar>Oil<cr>", "Oil Open" },
  -- p = { s = { ":w<bar>so %<bar>PackerSync<cr>", "PackerSync" } },
  -- t = {name = '+terminal', t = {":FloatermNew --wintype=popup --height=6", "terminal"}},
  l = {
    name = "LSP",
    i = { ":LspInfo<cr>", "Connected Language Servers" },
    k = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature Help" },
    K = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover Commands" },
    w = {
      '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>',
      "Add Workspace Folder"
    },
    W = {
      '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>',
      "Remove Workspace Folder"
    },
    l = {
      '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>',
      "List Workspace Folders"
    },
    L = {
      ':LspLog<cr>',
      "LSP LOG"
    },
    t = { '<cmd>lua vim.lsp.buf.type_definition()<cr>', "Type Definition" },
    e = { '<cmd>lua vim.diagnostic.open_float()<cr>', "Diag. Msg." },
    d = { '<cmd>lua vim.lsp.buf.definition()<cr>', "Go To Definition" },
    D = { '<cmd>vs<bar>lua vim.lsp.buf.definition()<cr>', "Go To Definition" },
    -- D = {'<cmd>lua vim.lsp.buf.declaration()<cr>', "Go To Declaration"},
    r = { '<cmd>lua vim.lsp.buf.references()<cr>', "References" },
    R = { '<cmd>lua vim.lsp.buf.rename()<cr>', "Rename Variable" },
    a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', "Code Action" },
    T = { ':lua require("lsp_lines").toggle()<cr>', "Toggle lsp_lines" },
    z = { ':LspRestart<cr>', "LspRestart" },
  },
  r = {
    name = "Run",
    a = {
    name = "Active",
     p = { "<C-W>v<C-W>l<cmd>term python %<cr>", "python active file" },
     i = { "<C-W>v<C-W>l<cmd>term mpiexec -n 1 python3 %<cr>", "python3 active file" },
     j = { "<C-W>s<C-W>l<cmd>term mpiexec -n 1 python3 %<cr>", "python3 active file" },
     b = { "<C-W>v<C-W>l<cmd>term bash %<cr>", "bash active file" },
     s = { UpdateMainPython, "Update Main Python File" },
     S = { UpdateMainbash, "Update Main bash File" },
     m = { RunMainPython, "Run MainPythonFile" },
     M = { RunMainbash, "Run Mainbash" },
    },
    b = { ":vs <bar>term . build.sh<cr>", "./build.sh" },
    p = {
      -- b = { ":vs <bar>term cd ../.. && bash build.sh<cr>", "build psi4" },
      b = { ":vs <bar>term cd .. && bash build.sh<cr>", "build psi4" },
      p = { ":vs<bar>term psi4 input.dat<cr>", "psi4 input.dat" },
      m = { "<C-W>v<C-W>l<cmd>term python3 mpi_jobs.py<cr>", "python3 mpi_jobs.py" },
      a = { ":vs<bar>term psi4 -n8 /theoryfs2/ds/amwalla3/projects/test_asapt/asapt.dat<cr>", "psi4 asapt.dat" },
      d = { ":vs<bar>term psi4 -n8 /theoryfs2/ds/amwalla3/projects/testing/dlpno_ccsd_disp/psi4.in <cr>", "psi4 dlpno_ccsd_disp" },
      o = { ":vs<bar>e /theoryfs2/ds/amwalla3/projects/test_asapt/asapt.out<cr>", "psi4 asapt.dat" },
      -- d = { ":vs<bar>term python3 ~/data/sapt_dft_testing/water_test.py<cr>", "saptdft testing" },
    },
    B = { ":vs <bar>term cd src/dispersion && bash build.sh<cr>", "./build.sh" },
    d = { ":vs <bar>term make build_and_test<cr>", "dftd4 build and run" },
    f = { ":vs <bar>term flask --app cdsg run --debug<cr>", "Run csdg" },
    r = { ":vs <bar>term cargo run <cr>", "cargo run" },
    s = { ":vs <bar>term swift %<cr>", "swift main.swift" },
    j = { ":vs <bar>term julia main.jl<cr>", "julia main.jl" },
    -- RUN TESTS
    t = {
      t = { "<C-W>v<C-W>l<cmd>term python3 tmp.py<cr>", "python3 tmp.py" },
      p = { ":vs<bar>term pytest tests.py<cr>", "PyTest" },
      k = { ":vs<bar>term pytest tests.py -k 'test_ATM_water'<cr>", "PyTest" },
      l = { PytestPythonFunction, "PyTest Specific" },
      o = { ":vs<bar>term python3 tests.py<cr>", "run tests.py" }
    },
    m = {
      m = { ":vs<bar>term make<cr>", "make" },
      d = { ":vs<bar>term make debug<cr>", "make" },
      t = { ":vs<bar>term make t", "make" },

    },
    n = { initJypterSession, "Init Jupyter Session" },
    I = {
      ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='vina' --system='proteinHs_ligandPQR' --testing --sf_components --verbosity=1 <cr>",
      "mpiexec main.py"
    },
    i = {
      a = {
        "<C-W>v<C-W>l<cmd>term mpiexec -n 1 python3 -u %<cr>",
        "mpiexec active python3"
      },
      f = {
        "<C-W>v<C-W>l<cmd>term mpiexec -n 4 python3 -u %<cr>",
        "mpiexec active 4 python3"
      },
      g = {
        "<C-W>v<C-W>l<cmd>term mpiexec -n 4 python3 -u % --grac_shifts<cr>",
        "mpiexec active 4 python3"
      },
      d = {
        "<C-W>v<C-W>l<cmd>term mpiexec -n 4 python3 -u % --level_theories SAPT_DFT_pbe0_adz<cr>",
        "mpiexec active 4 python3"
      },
      -- a = {
      --   ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='apnet_vina' --system='proteinHs_ligandPQR' --testing --verbosity=1<cr>",
      --   "mpiexec main.py"
      -- },
      i = {
        ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='apnet' --system='proteinHs_ligandPQR' --testing <cr>",
        "mpiexec main.py"
      },
      r = {
        ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='vina' --system='proteinHs_ligandPQR' --testing --verbosity=1 <cr>",
        "mpiexec main.py"
      },
      c = {
        ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='vina' --system='proteinHs_ligandPQR' --testing --sf_components --verbosity=1 <cr>",
        "mpiexec main.py"
      },
    },
    c = {
      ":vs<bar>term mpiexec -n 1 python3 -u create_db.py<cr>",
      "mpiexec create_db.py"
    },
    h = {
      ":vs<bar>term mpirun -n 8 --machinefile machineFile python3 -u mpi_jobs.py<cr>",
      "mpiexec main.py"
    },
    u = {
      ":vs<bar>term mpiexec -n 2 python3 -u main.py<cr>",
      "mpiexec main.py"
    },
    k = {
      ":vs<bar>term mpiexec -n 2 python3 -u %<cr>",
      "mpiexec active"
    },
    A = { "<C-W>v<C-W>l<cmd>term mpiexec -n 1 python3 %<cr>", "run active file" },
    P = { "<C-W>v<C-W>l<cmd>term python3 main.py<cr>", "python3 main.py" },
  },
  s = {
    name = '[S]earch', _ = 'which_key_ignore'
  },
  t = {
    name = "Terminal",
    t = { ":term<cr>", "Terminal" },
    T = { ":vs<bar>term<cr>", "Split+Terminal" },
    -- f = { toggle_float, "Floating Terminal" },
    -- l = {toggle_lazygit, "LazyGit"},
    -- y = { toggle_top, "top" },
    -- m = {toggle_neomutt, "NeoMutt"},
    d = {
      ":!dftd4 tmp.xyz --json t.json --param 1.0 0.9171 0.3385 2.883<cr>",
      "dftd4 test"
    },
    c = {
      ":vs<bar>term lscpu | grep -E '^Thread|^Core|^Socket|^CPU\\('<cr>",
      "lscpu grep"
    },
    r = { ':lua require("neotest").run.run()<CR>', "Neotest Pytest" },
    a = { ':lua require("neotest").run.run(vim.fn.expand("%f"))<CR>', "Neotest Pytest Active" },
    v = { ':lua require("neotest").run.attach()<CR>', "Neotest Attach" },
    p = { ':lua require("neotest").output.open({enter = true})<CR>', "Neotest Output" },
    o = { ':lua require("neotest").output_panel.toggle()<CR>', "Neotest Output" },
    w = { ':lua require("neotest").watch.toggle()<CR>', "Neotest Watch" },
    s = { ':lua require("neotest").summary.toggle()<CR>', "Neotest Summary" },
  },
  m = {
    name = "Markdown and LaTex",
    e = { "<cmd>EvalBlock<CR>", "EvalBlock" },
    p = {
      ":vs <bar> term pandoc -V geometry:margin=1in -C --bibliography=refs.bib --listings --csl=default.csl -s h.md -o h.pdf --pdf-engine=xelatex <CR>",
      "pdflatex md"
    },
    f = {
      "{jV}kgq", "Format Paragraph",
    }
  },
  y = {
    name = "Yank",
    y = { '"+y', "Yank to clipboard" },
    c = { YankCodeBlock, "Yank Code Block" },
  },
  -- nvimgp ChatGPT normal mode
  p = {
    c = { "<cmd>GpChatNew<cr>", "New Chat" },
    p = { "<cmd>GpChatToggle<cr>", "Toggle Chat" },
    f = { "<cmd>GpChatFinder<cr>", "Chat Finder" },

    ["<C-x>"] = { "<cmd>GpChatNew split<cr>", "New Chat split" },
    ["<C-v>"] = { "<cmd>GpChatNew vsplit<cr>", "New Chat vsplit" },
    ["<C-t>"] = { "<cmd>GpChatNew tabnew<cr>", "New Chat tabnew" },

    r = { "<cmd>GpRewrite<cr>", "Inline Rewrite" },
    a = { "<cmd>GpAppend<cr>", "Append (after)" },
    b = { "<cmd>GpPrepend<cr>", "Prepend (before)" },

    g = {
      name = "generate into new ..",
      p = { "<cmd>GpPopup<cr>", "Popup" },
      e = { "<cmd>GpEnew<cr>", "GpEnew" },
      n = { "<cmd>GpNew<cr>", "GpNew" },
      v = { "<cmd>GpVnew<cr>", "GpVnew" },
      t = { "<cmd>GpTabnew<cr>", "GpTabnew" },
    },

    n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
    s = { "<cmd>GpStop<cr>", "GpStop" },
    x = { "<cmd>GpContext<cr>", "Toggle GpContext" },
  },
}
local opts = { prefix = '<leader>', mode = "n" }
wk.register(normal_mappings, opts)
local visual_mappings = {
  t = {
    name = "LaTex",
    r = { Round_number, "Round Number" },
    c = { ":w !wc -w<CR>", "Word Count" },
  },
  -- nvimgp ChatGPT: visual mode
      p = {
        c = { ":<C-u>'<,'>GpChatNew<cr>", "Visual Chat New" },
        p = { ":<C-u>'<,'>GpChatPaste<cr>", "Visual Chat Paste" },
        t = { ":<C-u>'<,'>GpChatToggle<cr>", "Visual Toggle Chat" },

        ["<C-x>"] = { ":<C-u>'<,'>GpChatNew split<cr>", "Visual Chat New split" },
        ["<C-v>"] = { ":<C-u>'<,'>GpChatNew vsplit<cr>", "Visual Chat New vsplit" },
        ["<C-t>"] = { ":<C-u>'<,'>GpChatNew tabnew<cr>", "Visual Chat New tabnew" },

        r = { ":<C-u>'<,'>GpRewrite<cr>", "Visual Rewrite" },
        a = { ":<C-u>'<,'>GpAppend<cr>", "Visual Append (after)" },
        b = { ":<C-u>'<,'>GpPrepend<cr>", "Visual Prepend (before)" },
        i = { ":<C-u>'<,'>GpImplement<cr>", "Implement selection" },

        g = {
            name = "generate into new ..",
            p = { ":<C-u>'<,'>GpPopup<cr>", "Visual Popup" },
            e = { ":<C-u>'<,'>GpEnew<cr>", "Visual GpEnew" },
            n = { ":<C-u>'<,'>GpNew<cr>", "Visual GpNew" },
            v = { ":<C-u>'<,'>GpVnew<cr>", "Visual GpVnew" },
            t = { ":<C-u>'<,'>GpTabnew<cr>", "Visual GpTabnew" },
        },

        n = { "<cmd>GpNextAgent<cr>", "Next Agent" },
        s = { "<cmd>GpStop<cr>", "GpStop" },
        x = { ":<C-u>'<,'>GpContext<cr>", "Visual GpContext" },
    },
}
local opts_v = { prefix = '<leader>', mode = 'v' }
wk.register(visual_mappings, opts_v)

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- null_ls.builtins.formatting.stylua,
    -- null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.completion.spell,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.latexindent,
  },
})

-- Function to check line count and disable LSP if above threshold
function Check_line_count()
    local line_count = vim.fn.line('$')
    if line_count > 10000 then
        print("Disabling LSP for large file...")
        vim.lsp.stop_client()
    end
end

-- Automatically check line count on BufEnter event
vim.cmd([[autocmd BufEnter * lua Check_line_count()]])

-- null_ls.builtins.formatting.latexindent.with({
--   extra_args = { "-l", UserHome .. "/.indentconfig.yaml", "-m" },
-- })
-- vim: ts=2 sts=2 sw=2 et
