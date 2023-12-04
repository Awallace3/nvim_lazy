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

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

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

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {},
  -- gopls = {},
  pyright = {},
  rust_analyzer = {},
  julials = {},
  ltex = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

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
      -- cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
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
      -- on_attach = function(client, bufnr)
      --     on_attach(client, bufnr)
      --     -- Disable automatic formatexpr since the LS.jl formatter isn't so nice.
      --     vim.bo[bufnr].formatexpr = ''
      -- end,
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end,
  ["ltex"] = function()
    lspconfig.ltex.setup {
      enabled = { "latex", "tex", "bib", "markdown" },
      on_attach = on_attach,
      capabilities = capabilities,
      checkFrequency = "save",
      language = "en-US",
      settings = {
        ltex = {
          dictionary = {
            ["en-US"] = words,
          },
          disabledRules = {
            ['en-US'] = {
              "ARROWS",
            },
          }
        },
      },
    }
  end,
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

-- determine filetype for formatter, python different from others
local determine_formatter = function()
  local filetype = vim.bo.filetype
  if filetype == "python" then
    vim.cmd("Format")
  elseif filetype == "htmldjango" then
    vim.cmd("Format")
  else
    vim.lsp.buf.format()
  end
end

GetPath = function(str, sep)
  sep = sep or '/'
  return str:match("(.*" .. sep .. ")")
end
-- get directory of python3_host_prog path
local nvim_bin_cmd = "silent !" .. GetPath(vim.g.python3_host_prog)

Formatter = function()
  local filetype = vim.bo.filetype
  if filetype == "python" then
    vim.cmd("write")
    local cmd = nvim_bin_cmd .. "black --quiet" .. " " .. vim.fn.expand("%:p")
    vim.cmd(cmd)
    vim.cmd("e!")
  elseif filetype == "htmldjango" or filetype == "html" then
    vim.cmd("write")
    local cmd = nvim_bin_cmd .. "djlint" .. " --reformat --indent 4 " .. vim.fn.expand("%:p")
    print(cmd)
    vim.cmd(cmd)
    vim.cmd("e!")
  elseif filetype == "css" then
    vim.cmd("write")
    local cmd = nvim_bin_cmd .. "stylelint" .. " --fix " .. vim.fn.expand("%:p")
    print(cmd)
    vim.cmd(cmd)
    vim.cmd("e!")
  elseif filetype == "lua" or filetype == "tex" or filetype == "julia" then
    vim.lsp.buf.format()
  else
    vim.lsp.buf.formatting()
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

local normal_mappings = {
  q = { ":bn<bar>bd #<CR>", "Close Buffer" },
  Q = { ":wq<cr>", "Save & Quit" },
  -- w = {":w<cr>", "Save"},
  x = { ":bdelete<cr>", "Close" },
  c = {
    name = "ChatGPT",
    c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
    e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
    g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
    t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
    k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
    d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
    a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
    o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
    s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
    f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
    x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
    r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
    l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
  },
  d = {
    name = "Database",
    u = { "<Cmd>DBUIToggle<Cr>", "Toggle UI" },
    f = { "<Cmd>DBUIFindBuffer<Cr>", "Find buffer" },
    r = { "<Cmd>DBUIRenameBuffer<Cr>", "Rename buffer" },
    q = { "<Cmd>DBUILastQueryInfo<Cr>", "Last query info" },
  },
  e = {
    name = "Edit Config",
    E = { ":vs<bar>e ~/.config/nvim/init.lua<cr>", "Edit config" },
    e = { ":e<bar>e ~/.config/nvim/init.lua<cr>", "Edit config" },
    c = { ":e<bar>e ~/.config/nvim/lua/chatgpt-config.lua<cr>", "Edit config" },
    W = {
      ":vs<bar>e ~/.config/nvim/lua/whichkey-config/init.lua<cr>",
      "Edit config"
    },
    p = {
      ":e ~/.config/nvim/lua/custom/plugins<cr>",
      "Edit Plugins"
    },
    P = {
      ":vs<bar>e ~/.config/nvim/lua/custom/plugins<cr>",
      "Edit Plugins"
    },
    s = { ":e<bar>e ~/.config/nvim/snippets<cr>", "Edit config" },
    S = {
      ":vs<bar>e ~/.config/nvim/lua/luasnip-config.lua<bar>40<cr>",
      "Edit Snippets"
    },
    l = {
      ":e ~/.config/nvim/lua/lsp-setup.lua<cr>",
      "Edit cmp"
    },
    L = {
      ":vs<bar>e ~/.config/nvim/lua/lsp-setup.lua<cr>",
      "Edit cmp (split)"
    }
    -- S = {":vs<bar>e ~/.config/nvim/snippets<cr>", "Edit config"}
  },
  F = { Formatter, "Format Buffer" },
  g = {
    -- gitgutter
    name = "Git",
    d = { ":Git difftool<cr>", "Git Diff" },
    n = { ":GitGutterNextHunk<cr>", "Next Hunk" },
    p = { ":GitGutterPrevHunk<cr>", "Prev Hunk" },
    a = { ":GitGutterStageHunk<cr>", "Stage Hunk" },
    u = { ":GitGutterUndoHunk<cr>", "Undo Hunk" },
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
  p = { s = { ":w<bar>so %<bar>PackerSync<cr>", "PackerSync" } },
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
    d = { '<cmd>lua vim.lsp.buf.definition()<cr>', "Go To Definition" },
    D = { '<cmd>vs<bar>lua vim.lsp.buf.definition()<cr>', "Go To Definition" },
    -- D = {'<cmd>lua vim.lsp.buf.declaration()<cr>', "Go To Declaration"},
    r = { '<cmd>lua vim.lsp.buf.references()<cr>', "References" },
    R = { '<cmd>lua vim.lsp.buf.rename()<cr>', "Rename Variable" },
    a = { '<cmd>lua vim.lsp.buf.code_action()<cr>', "Code Action" },
    T = { ':lua require("lsp_lines").toggle()<cr>', "Toggle lsp_lines" }
  },
  r = {
    name = "Run",
    b = { ":vs <bar>term . build.sh<cr>", "./build.sh" },
    p = {
      -- b = { ":vs <bar>term cd ../.. && bash build.sh<cr>", "build psi4" },
      b = { ":vs <bar>term cd .. && bash build.sh<cr>", "build psi4" },
      p = { ":vs<bar>term psi4 input.dat<cr>", "psi4 input.dat" },
    },
    B = { ":vs <bar>term cd src/dispersion && bash build.sh<cr>", "./build.sh" },
    d = { ":vs <bar>term make build_and_test<cr>", "dftd4 build and run" },
    f = { ":vs <bar>term flask --app cdsg run --debug<cr>", "Run csdg" },
    r = { ":w <bar>so %<cr>", "Save and Source" },
    j = { ":vs <bar>term julia main.jl<cr>", "julia main.jl" },
    -- RUN TESTS
    t = {
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
    i = {
      ":vs<bar>term mpiexec -n 2 python3 -u mpi_jobs.py<cr>",
      "mpiexec main.py"
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
      ":vs<bar>term mpiexec -n 2 python3 -u db.py<cr>",
      "mpiexec main.py"
    },
    a = { ":vs<bar> term python3 %<cr>", "run active file" }
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
  o = {
    name = "Overseer",
    o = { ":OverseerToggle<cr>", "Overseer Toggle" },
    r = { ":OverseerRun<cr>", "Overseer Run" },
    c = { ":OverseerRun ", "Overseer Run template" },
    l = { ":OverseerLoadBundle<cr>", "Overseer Load Bundle" },
    d = { ":OverseerDeleteBundle<cr>", "Overseer Delete Bundle" },
    h = { ':lua require("notify").history()<cr>', "Notify History" },
    n = { ':Notifications<cr>', "Notify Notifications" },
    p = { ":OverseerRun python3 main.py<cr>", "Overseer Run Python" }

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
  }
}
local opts = { prefix = '<leader>', mode = "n" }
wk.register(normal_mappings, opts)
local visual_mappings = {
  t = {
    name = "LaTex",
    r = { Round_number, "Round Number" },

  }
}
local opts_v = { prefix = '<leader>', mode = 'v' }
wk.register(visual_mappings, opts_v)

-- vim: ts=2 sts=2 sw=2 et
