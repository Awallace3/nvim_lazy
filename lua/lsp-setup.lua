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
    local ts_utils = require 'nvim-treesitter.ts_utils'
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
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
        vim.cmd('normal! v')

        local end_position = vim.api.nvim_buf_line_count(0) == end_row and end_col or end_col + 1
        vim.api.nvim_win_set_cursor(0, { end_row + 1, end_position })
        vim.cmd('normal! y')
        print("Code block yanked")
        return
      end
      node = node:parent() -- Move to the parent node
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
  denols = {},
  rust_analyzer = {},
  julials = {},
  ltex = {},
  texlab = {},
  fortls = {},
  -- yamlls = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
  -- jedi_language_server = {},
  pylsp = {},
  ruff = {},
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

local formatters = {
  -- black = {},
  ruff = {},
  stylua = {},
  clang_format = {},
}

local ensure_installed = vim.tbl_keys(servers)

mason_lspconfig.setup {
  ensure_installed = ensure_installed,
}

MainPythonFile = "main.py"
UpdateMainPython = function()
  -- get active buffer's file path and name and update global variable MainPythonFile (should be absolute path)
  MainPythonFile = vim.fn.expand("%:p")
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



function Get_visual_selection()
  -- 0.52917721067
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

function Write_coords_to_tmp_xyz(coords)
  os.remove("tmp.xyz")
  local file = io.open("tmp.xyz", "w")

  if file == nil then
    print("Error opening file")
    return
  end
  -- print("Writing to file")
  local n_atoms = 0
  for _ in coords:gmatch("[^\r\n]+") do
    n_atoms = n_atoms + 1
  end
  print(coords)
  file:write(n_atoms)
  file:write("\n\n")
  file:write(coords)
  file:write("\n")
  file:close()
end

function Jmol_visual_xyz()
  local coords = Get_visual_selection()
  Write_coords_to_tmp_xyz(coords)
  print("Running jmol")
  print("jmol tmp.xyz")
  io.popen("jmol tmp.xyz")
end

helper = require("helper")

function Pymol_visual_xyz()
  local coords = Get_visual_selection()
  Write_coords_to_tmp_xyz(coords)
  print("Running Pymol")
  print("pymol tmp.xyz")
  vim.cmd [[
        vs
        " term pymol tmp.xyz
        term pymol ~/default_pymol.pml
    ]]
end

function Pymol_visual_xyz_convert()
  local coords = Get_visual_selection()
  local new_coords = ""
  for line in coords:gmatch("[^\r\n]+") do
    local el, x, y, z = line:match("([%d])%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)")
    el = helper.atomic_number_to_element(tonumber(el))
    x = x * 1
    y = y * 1
    z = z * 1
    new_coords = new_coords .. el .. " " .. x .. " " .. y .. " " .. z .. "\n"
  end
  Write_coords_to_tmp_xyz(new_coords)
  print("Running Pymol")
  print("pymol tmp.xyz")
  vim.cmd [[
        vs
        term pymol ~/default_pymol.pml
    ]]
end

function Pymol_visual_xyz_bohr_convert()
  local coords = Get_visual_selection()
  -- need to convert bohr to angstrom
  -- 1 bohr = 0.52917721067 angstrom
  local bohr_to_angstrom = 0.52917721067
  local new_coords = ""
  for line in coords:gmatch("[^\r\n]+") do
    local el, x, y, z = line:match("([%d])%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)")
    el = helper.atomic_number_to_element(tonumber(el))
    x = x * bohr_to_angstrom
    y = y * bohr_to_angstrom
    z = z * bohr_to_angstrom
    new_coords = new_coords .. el .. " " .. x .. " " .. y .. " " .. z .. "\n"
  end
  Write_coords_to_tmp_xyz(new_coords)
  print("Running Pymol")
  print("pymol tmp.xyz")
  vim.cmd [[
        vs
        term pymol ~/default_pymol.pml
    ]]
end

function Pymol_visual_xyz_bohr()
  local coords = Get_visual_selection()
  -- need to convert bohr to angstrom
  -- 1 bohr = 0.52917721067 angstrom
  local bohr_to_angstrom = 0.52917721067
  local new_coords = ""
  for line in coords:gmatch("[^\r\n]+") do
    local el, x, y, z = line:match("([%d])%s+([%d%.%-]+)%s+([%d%.%-]+)%s+([%d%.%-]+)")
    x = x * bohr_to_angstrom
    y = y * bohr_to_angstrom
    z = z * bohr_to_angstrom
    new_coords = new_coords .. el .. " " .. x .. " " .. y .. " " .. z .. "\n"
  end
  Write_coords_to_tmp_xyz(new_coords)
  print("Running Pymol")
  print("pymol tmp.xyz")
  vim.cmd [[
        vs
        term pymol ~/default_pymol.pml
    ]]
end

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
  -- ["ruff"] = function()
  --   lspconfig.ruff.setup {
  --     on_attach = on_attach,
  --     capabilities = capabilities,
  --   }
  -- end,
  ["pylsp"] = function()
    lspconfig.pylsp.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = { enabled = false },
            pyflakes = { enabled = false },
            pylint = { enabled = false },
            -- yapf = { enabled = false },
            -- flake8 = { enabled = false },
            -- mypy = { enabled = false },
            -- isort = { enabled = false },
            -- jedi_completion = { enabled = false },
            -- jedi_definition = { enabled = false },
            -- jedi_hover = { enabled = false },
            -- jedi_references = { enabled = false },
            -- jedi_signature_help = { enabled = false },
            -- jedi_symbols = { enabled = false },
            -- mccabe = { enabled = false },
            -- pydocstyle = { enabled = false },
            -- rope_completion = { enabled = false },
            -- rope_definition = { enabled = false },
            -- rope_hover = { enabled = false },
            -- rope_references = { enabled = false },
            -- rope_signature_help = { enabled = false },
          },
        },
      },
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
      on_attach = function(client, bufnr)
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end,
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
          latexindent = {
            extra_args = { "-l", vim.fn.expand("$HOME/.indentconfig.yaml"), "-m" },
            -- lua get from $HOME/latexindent.yaml
            -- ['local'] = vim.fn.expand("$HOME/latexindent.yaml"),
            -- ['local'] = UserHome .. "/latexindent.yaml",
          },
          bibtexFormatter = 'texlab',
          formatterLineLength = 30,
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

require('which-key').add {
  { "<leader>c",  group = "[C]ode" },
  { "<leader>c_", hidden = true },
  -- { "<leader>d",  group = "[D]ocument" },
  -- { "<leader>d_", hidden = true },
  -- { "<leader>g",  group = "[G]it" },
  -- { "<leader>g_", hidden = true },
  { "<leader>h",  group = "More git" },
  { "<leader>h_", hidden = true },
  -- { "<leader>s",  group = "[S]earch" },
  -- { "<leader>s_", hidden = true },
  { "<leader>w",  group = "[W]orkspace" },
  { "<leader>w_", hidden = true },
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
  cmd = "term pytest " .. fname .. " --basetemp=tmp -k '" .. function_name .. "'"
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
    local cmd = nvim_mason_bin .. "djlint " .. vim.fn.expand("%:p") .. " --reformat --indent 2"
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
local mcp_config_path = os.getenv("XDG_CONFIG_HOME") .. "/mcp-hub"

local insert_mappings = {
  { "<C-k>", '<cmd>lua vim.lsp.buf.hover()<cr>', desc = 'Hover Commands' }
}
local insert_opts = { mode = "i" }
wk.add(insert_mappings, insert_opts)

local function patternReplaceIncrement()
  -- Prompt the user for the pattern and replacement text
  local pattern = vim.fn.input("Pattern to replace: ")

  -- Initialize the increment variable
  local i = 1

  -- Define a function to perform the replacement
  local function replace_line(line_num)
    local line = vim.fn.getline(line_num)
    if line:find(pattern) then
      -- Create the replacement text with the current increment
      local replacement = pattern .. "_" .. i
      -- Perform the substitution in the line
      local new_line = line:gsub(pattern, replacement)
      vim.fn.setline(line_num, new_line)
      -- Increment the counter
      i = i + 1
    end
  end

  -- Iterate over all lines in the buffer
  for line_num = 1, vim.fn.line('$') do
    replace_line(line_num)
  end
end

local function capture_and_copy(cmd)
  -- Create a command to redirect the output to a variable
  local output = vim.api.nvim_exec(cmd, true)

  -- Copy the output to the clipboard
  vim.fn.setreg('+', output)
end


local normal_mappings = {
  {
    { "<leader>F",    Formatter,                                                                                                                                                         desc = "Format Buffer" },
    { "<leader>Q",    ":wq<cr>",                                                                                                                                                         desc = "Save & Quit" },
    { "<leader>d",    group = "Database" },
    { "<leader>df",   "<Cmd>DBUIFindBuffer<Cr>",                                                                                                                                         desc = "Find buffer" },
    { "<leader>dq",   "<Cmd>DBUILastQueryInfo<Cr>",                                                                                                                                      desc = "Last query info" },
    { "<leader>dr",   "<Cmd>DBUIRenameBuffer<Cr>",                                                                                                                                       desc = "Rename buffer" },
    { "<leader>du",   "<Cmd>DBUIToggle<Cr>",                                                                                                                                             desc = "Toggle UI" },
    { "<leader>e",    group = "Edit Config" },
    { "<leader>eE",   ":vs<bar>e " .. nvim_config_path .. "/init.lua<cr>",                                                                                                               desc = "init.lua (split)" },
    { "<leader>eL",   ":vs<bar>e " .. nvim_config_path .. "/lsp-setup.lua<cr>",                                                                                                          desc = "Edit lsp (split)" },
    -- { "<leader>eM",   ":vs<bar>e" .. nvim_config_path .. "/lua/cmp-setup.lua<cr>",                                                                                                       desc = "Edit cmp (split)" },
    { "<leader>eO",   ":vs<bar>e" .. nvim_config_path .. "/lua/options.lua<cr>",                                                                                                         desc = "Edit Options (split)" },
    { "<leader>eP",   ":vs<bar>e" .. nvim_config_path .. "/lua/custom/plugins<cr>",                                                                                                      desc = "Edit Plugins (split)" },
    { "<leader>eS",   ":vs<bar>e" .. nvim_config_path .. "/lua/luasnip-config.lua<bar>40<cr>",                                                                                           desc = "Edit Snippets (split)" },
    { "<leader>ec",   ":e" .. nvim_config_path .. "/lua/chatgpt-config.lua<cr>",                                                                                                         desc = "Edit config" },
    { "<leader>ee",   ":e" .. nvim_config_path .. "/init.lua<cr>",                                                                                                                       desc = "Edit config" },
    { "<leader>em",   ":e" .. mcp_config_path .. "/mcp-servers.json<cr>",                                                                                                                       desc = "Edit mcp-servers.json" },
    { "<leader>ef",   ":e" .. nvim_config_path .. "/nvim_simplified<cr>",                                                                                                                desc = "Edit Last" },
    { "<leader>el",   ":e" .. nvim_config_path .. "/lua/lsp-setup.lua<cr>",                                                                                                              desc = "Edit lsp" },
    -- { "<leader>em",   ":e" .. nvim_config_path .. "/lua/cmp-setup.lua<cr>",                                                                                                              desc = "Edit cmp" },
    { "<leader>eo",   ":e" .. nvim_config_path .. "/lua/options.lua<cr>",                                                                                                                desc = "Edit Options" },
    { "<leader>ep",   ":e" .. nvim_config_path .. "/lua/custom/plugins<cr>",                                                                                                             desc = "Edit Plugins" },
    { "<leader>es",   ":e" .. nvim_config_path .. "/snippets<cr>",                                                                                                                       desc = "Edit config" },
    { "<leader>f",    group = "Find" },
    { "<leader>fF",   find_files_different_root,                                                                                                                                         desc = "Telescope Find Files" },
    { "<leader>fR",   grep_files_different_root,                                                                                                                                         desc = "Telescope Live Grep" },
    { "<leader>fa",   ':lua require("harpoon.mark").add_file()<cr>',                                                                                                                     desc = "Harpoon Add" },
    { "<leader>fb",   ":Telescope buffers<cr>",                                                                                                                                          desc = "Telescope Buffers" },
    { "<leader>fd",   ":Telescope help_tags<cr>",                                                                                                                                        desc = "Telescope Help Tags" },
    { "<leader>ff",   ":Telescope find_files<cr>",                                                                                                                                       desc = "Telescope Find Files" },
    { "<leader>fh",   ":Telescope harpoon marks<cr>",                                                                                                                                    desc = "Telescope Harpoon" },
    { "<leader>fm",   ':lua require("harpoon.ui").toggle_quick_menu()<cr>',                                                                                                              desc = "Harpoon Menu" },
    { "<leader>fp",   ":echo expand('%:p')<CR>",                                                                                                                                         desc = "Current File Path" },
    { "<leader>fr",   ":Telescope live_grep<cr>",                                                                                                                                        desc = "Telescope Live Grep" },
    { "<leader>ft",   get_filetype,                                                                                                                                                      desc = "Current File Path" },
    { "<leader>g",    group = "Git" },
    { "<leader>gP",   ":Git push<cr>",                                                                                                                                                   desc = "Git Push" },
    { "<leader>gS",   ":lua require('neogit').open({ cwd = vim.fn.expand('%:p:h')})<CR>",                                                                                                desc = "Git Status" },
    { "<leader>gaf",  ":Gw<cr>",                                                                                                                                                         desc = "Add File" },
    { "<leader>gb",   ":Git blame<cr>",                                                                                                                                                  desc = "Git Blame" },
    { "<leader>gc",   ":Git commit<bar>:startinsert<cr>",                                                                                                                                desc = "Git Commit" },
    { "<leader>gd",   ":Git difftool<cr>",                                                                                                                                               desc = "Git Diff" },
    { "<leader>gs",   ":lua require('neogit').open()<CR>",                                                                                                                               desc = "Git Status" },
    { "<leader>i",    group = "Insert" },
    { "<leader>it",   "o* [ ] ",                                                                                                                                                         desc = "Insert Task" },
    { "<leader>l",    group = "LSP" },
    { "<leader>lD",   "<cmd>vs<bar>lua vim.lsp.buf.definition()<cr>",                                                                                                                    desc = "Go To Definition" },
    { "<leader>lK",   "<cmd>lua vim.lsp.buf.hover()<cr>",                                                                                                                                desc = "Hover Commands" },
    { "<leader>lL",   ":LspLog<cr>",                                                                                                                                                     desc = "LSP LOG" },
    { "<leader>ls",   ":LspStop<cr>",                                                                                                                                                    desc = "LSP Stop" },
    { "<leader>lR",   "<cmd>lua vim.lsp.buf.rename()<cr>",                                                                                                                               desc = "Rename Variable" },
    { "<leader>lT",   ':lua require("lsp_lines").toggle()<cr>',                                                                                                                          desc = "Toggle lsp_lines" },
    { "<leader>lW",   "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>",                                                                                                              desc = "Remove Workspace Folder" },
    { "<leader>la",   "<cmd>lua vim.lsp.buf.code_action()<cr>",                                                                                                                          desc = "Code Action" },
    { "<leader>ld",   "<cmd>lua vim.lsp.buf.definition()<cr>",                                                                                                                           desc = "Go To Definition" },
    { "<leader>le",   "<cmd>lua vim.diagnostic.open_float()<cr>",                                                                                                                        desc = "Diag. Msg." },
    { "<leader>li",   ":LspInfo<cr>",                                                                                                                                                    desc = "Connected Language Servers" },
    { "<leader>lk",   "<cmd>lua vim.lsp.buf.signature_help()<cr>",                                                                                                                       desc = "Signature Help" },
    { "<leader>ll",   "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",                                                                                           desc = "List Workspace Folders" },
    { "<leader>lr",   "<cmd>lua vim.lsp.buf.references()<cr>",                                                                                                                           desc = "References" },
    { "<leader>lt",   "<cmd>lua vim.lsp.buf.type_definition()<cr>",                                                                                                                      desc = "Type Definition" },
    { "<leader>lw",   "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>",                                                                                                                 desc = "Add Workspace Folder" },
    { "<leader>lz",   ":LspRestart<cr>",                                                                                                                                                 desc = "LspRestart" },
    { "<leader>m",    group = "Markdown and LaTex" },
    { "<leader>me",                           "<cmd>lua require 'mdeval'.eval_code_block()<CR>",                                                                                                                                              desc = "EvalBlock" },
    { "<leader>mf",   "{jV}kgq",                                                                                                                                                         desc = "Format Paragraph" },
    { "<leader>mp",   ":vs <bar> term pandoc -V geometry:margin=1in -C --bibliography=refs.bib --listings --csl=default.csl -s h.md -o h.pdf --pdf-engine=xelatex <CR>",                 desc = "pdflatex md" },
    { "<leader>n",    ":Oil<cr>",                                                                                                                                                        desc = "Tree Toggle" },
    -- { "<leader>pa",   "<cmd>CodeCompanionActions<cr>",                                                                                                                                   desc = "CodeCompanionActions" },
    -- { "<leader>pp",   "<cmd>CodeCompanion<cr>",                                                                                                                                          desc = "CodeCompanion" },
    { "<leader>pa", "<cmd>AvanteAsk<cr>",                                                                                                                                       desc = "AvanteAsk" },
    { "<leader>ph", "<cmd>MCPHub<cr>",                                                                                                                                       desc = "MCPHub" },
    -- { "<leader>p<C-t>", "<cmd>GpChatNew tabnew<cr>",                                                                                                                                       desc = "New Chat tabnew" },
    -- { "<leader>p<C-v>", "<cmd>GpChatNew vsplit<cr>",                                                                                                                                       desc = "New Chat vsplit" },
    -- { "<leader>p<C-x>", "<cmd>GpChatNew split<cr>",                                                                                                                                        desc = "New Chat split" },
    -- { "<leader>pa",     "<cmd>GpAppend<cr>",                                                                                                                                               desc = "Append (after)" },
    -- { "<leader>pb",     "<cmd>GpPrepend<cr>",                                                                                                                                              desc = "Prepend (before)" },
    -- { "<leader>pc",     "<cmd>GpChatNew<cr>",                                                                                                                                              desc = "New Chat" },
    -- { "<leader>pf",     "<cmd>GpChatFinder<cr>",                                                                                                                                           desc = "Chat Finder" },
    -- { "<leader>pg",     group = "generate into new .." },
    -- { "<leader>pge",    "<cmd>GpEnew<cr>",                                                                                                                                                 desc = "GpEnew" },
    -- { "<leader>pgn",    "<cmd>GpNew<cr>",                                                                                                                                                  desc = "GpNew" },
    -- { "<leader>pgp",    "<cmd>GpPopup<cr>",                                                                                                                                                desc = "Popup" },
    -- { "<leader>pgt",    "<cmd>GpTabnew<cr>",                                                                                                                                               desc = "GpTabnew" },
    -- { "<leader>pgv",    "<cmd>GpVnew<cr>",                                                                                                                                                 desc = "GpVnew" },
    -- { "<leader>pn",     "<cmd>GpNextAgent<cr>",                                                                                                                                            desc = "Next Agent" },
    -- { "<leader>pp",     "<cmd>GpChatToggle<cr>",                                                                                                                                           desc = "Toggle Chat" },
    -- { "<leader>pr",     "<cmd>GpRewrite<cr>",                                                                                                                                              desc = "Inline Rewrite" },
    -- { "<leader>ps",     "<cmd>GpStop<cr>",                                                                                                                                                 desc = "GpStop" },
    -- { "<leader>px",     "<cmd>GpContext<cr>",                                                                                                                                              desc = "Toggle GpContext" },
    { "<leader>q",    ":bn<bar>bd #<CR>",                                                                                                                                                desc = "Close Buffer" },
    { "<leader>r",    group = "Run" },
    { "<leader>rA",   "<C-W>v<C-W>l<cmd>term mpiexec -n 1 python3 %<cr>",                                                                                                                desc = "run active file" },
    { "<leader>rB",   ":vs <bar>term cd src/dispersion && bash build.sh<cr>",                                                                                                            desc = "./build.sh" },
    { "<leader>rI",   ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='vina' --system='proteinHs_ligandPQR' --testing --sf_components --verbosity=1 <cr>", desc = "mpiexec main.py" },
    { "<leader>rP",   "<C-W>v<C-W>l<cmd>term python3 main.py<cr>",                                                                                                                       desc = "python3 main.py" },
    { "<leader>ra",   group = "Active" },
    { "<leader>rab",  "<C-W>v<C-W>l<cmd>term bash %<cr>",                                                                                                                                desc = "bash active file" },
    { "<leader>rab",  RunMainbash,                                                                                                                                                       desc = "RunMainbash" },
    { "<leader>raB",  UpdateMainbash,                                                                                                                                                    desc = "RunMainbash" },
    { "<leader>rai",  "<C-W>v<C-W>l<cmd>term mpiexec -n 1 python3 %<cr>",                                                                                                                desc = "python3 active file" },
    { "<leader>raj",  "<C-W>s<C-W>l<cmd>term mpiexec -n 1 python3 %<cr>",                                                                                                                desc = "python3 active file" },
    { "<leader>rap",  "<C-W>v<C-W>l<cmd>term python %<cr>",                                                                                                                              desc = "python active file" },
    { "<leader>ras",  UpdateMainPython,                                                                                                                                                  desc = "UpdateMainPython" },
    { "<leader>ram",  RunMainPython,                                                                                                                                                     desc = "RunMainPython" },
    { "<leader>rb",   ":vs <bar>term . build.sh<cr>",                                                                                                                                    desc = "./build.sh" },
    { "<leader>rc",   ":vs<bar>term mpiexec -n 1 python3 -u create_db.py<cr>",                                                                                                           desc = "mpiexec create_db.py" },
    { "<leader>rd",   ":vs <bar>term make build_and_test<cr>",                                                                                                                           desc = "dftd4 build and run" },
    { "<leader>rf",   ":vs <bar>term flask --app cdsg run --debug<cr>",                                                                                                                  desc = "Run csdg" },
    { "<leader>ry",   ":vs <bar>term yarn run start<cr>",                                                                                                                  desc = "yarn run start" },
    { "<leader>rN",   ":vs <bar>term npm run start<cr>",                                                                                                                  desc = "npm run start" },
    { "<leader>rh",   ":vs<bar>term mpirun -n 8 --machinefile machineFile python3 -u mpi_jobs.py<cr>",                                                                                   desc = "mpiexec main.py" },
    { "<leader>ria",  "<C-W>v<C-W>l<cmd>term mpiexec -n 1 python3 -u %<cr>",                                                                                                             desc = "mpiexec active python3" },
    { "<leader>ric",  ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='vina' --system='proteinHs_ligandPQR' --testing --sf_components --verbosity=1 <cr>", desc = "mpiexec main.py" },
    { "<leader>rii",  ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='apnet' --system='proteinHs_ligandPQR' --testing <cr>",                              desc = "mpiexec main.py" },
    { "<leader>rir",  ":vs<bar>term mpiexec -n 1 python3 -u mpi_jobs.py --serial --scoring_function='vina' --system='proteinHs_ligandPQR' --testing --verbosity=1 <cr>",                 desc = "mpiexec main.py" },
    { "<leader>rj",   ":vs <bar>term julia main.jl<cr>",                                                                                                                                 desc = "julia main.jl" },
    { "<leader>rk",   ":vs<bar>term mpiexec -n 2 python3 -u %<cr>",                                                                                                                      desc = "mpiexec active" },
    { "<leader>rmd",  ":vs<bar>term make debug<cr>",                                                                                                                                     desc = "make" },
    { "<leader>rmm",  ":vs<bar>term make<cr>",                                                                                                                                           desc = "make" },
    { "<leader>rmt",  ":vs<bar>term make t",                                                                                                                                             desc = "make" },
    { "<leader>rn",   initJypterSession,                                                                                                                                                 desc = "Init Jupyter Session" },
    { "<leader>rpa",  ":vs<bar>term psi4 -n8 /theoryfs2/ds/amwalla3/projects/test_asapt/asapt.dat<cr>",                                                                                  desc = "psi4 asapt.dat" },
    { "<leader>rpb",  ":vs <bar>term cd .. && bash build.sh<cr>",                                                                                                                        desc = "build psi4" },
    { "<leader>rpd",  ":vs<bar>term python3 ~/data/sapt_dft_testing/water_test.py<cr>",                                                                                                  desc = "saptdft testing" },
    { "<leader>rpm",  "<C-W>v<C-W>l<cmd>term python3 mpi_jobs.py<cr>",                                                                                                                   desc = "python3 mpi_jobs.py" },
    { "<leader>rpo",  ":vs<bar>e /theoryfs2/ds/amwalla3/projects/test_asapt/asapt.out<cr>",                                                                                              desc = "psi4 asapt.dat" },
    { "<leader>rpP",  ":vs<bar>term psi4 input.dat<cr>",                                                                                                                                 desc = "psi4 input.dat" },
    { "<leader>rpp",  ":vs<bar>term psi4 %<cr>",                                                                                                                                         desc = "psi4 input.dat" },
    { "<leader>rr",   ":vs <bar>term cargo run <cr>",                                                                                                                                    desc = "cargo run" },
    { "<leader>rs",   ":vs <bar>term swift %<cr>",                                                                                                                                       desc = "swift main.swift" },
    { "<leader>rtk",  ":vs<bar>term pytest tests.py -k 'test_ATM_water'<cr>",                                                                                                            desc = "PyTest" },
    { "<leader>rtl",  PytestPythonFunction,                                                                                                                                              desc = "PyTest Specific" },
    { "<leader>rto",  ":vs<bar>term python3 tests.py<cr>",                                                                                                                               desc = "run tests.py" },
    { "<leader>rtp",  ":vs<bar>term pytest tests.py<cr>",                                                                                                                                desc = "PyTest" },
    { "<leader>rtt",  "<C-W>v<C-W>l<cmd>term python3 tmp.py<cr>",                                                                                                                        desc = "python3 tmp.py" },
    { "<leader>ru",   ":vs<bar>term mpiexec -n 2 python3 -u main.py<cr>",                                                                                                                desc = "mpiexec main.py" },
    { "<leader>s",    group = "[S]earch" },
    { "<leader>s_",   hidden = true },
    { "<leader>t",    group = "Terminal" },
    { "<leader>tT",   ":vs<bar>term<cr>",                                                                                                                                                desc = "Split+Terminal" },
    { "<leader>ta",   ':lua require("neotest").run.run(vim.fn.expand("%f"))<CR>',                                                                                                        desc = "Neotest Pytest Active" },
    { "<leader>tc",   ":vs<bar>term lscpu | grep -E '^Thread|^Core|^Socket|^CPU\\('<cr>",                                                                                                desc = "lscpu grep" },
    { "<leader>td",   ":!dftd4 tmp.xyz --json t.json --param 1.0 0.9171 0.3385 2.883<cr>",                                                                                               desc = "dftd4 test" },
    { "<leader>to",   ':lua require("neotest").output_panel.toggle()<CR>',                                                                                                               desc = "Neotest Output" },
    { "<leader>tp",   ':lua require("neotest").output.open({enter = true})<CR>',                                                                                                         desc = "Neotest Output" },
    { "<leader>tr",   ':lua require("neotest").run.run()<CR>',                                                                                                                           desc = "Neotest Pytest" },
    { "<leader>ts",   ':lua require("neotest").summary.toggle()<CR>',                                                                                                                    desc = "Neotest Summary" },
    { "<leader>tt",   ":term<cr>",                                                                                                                                                       desc = "Terminal" },
    { "<leader>tv",   ':lua require("neotest").run.attach()<CR>',                                                                                                                        desc = "Neotest Attach" },
    { "<leader>tw",   ':lua require("neotest").watch.toggle()<CR>',                                                                                                                      desc = "Neotest Watch" },
    { "<leader>x",    ":bdelete<cr>",                                                                                                                                                    desc = "Close" },
    { "<leader>y",    group = "Yank" },
    { "<leader>yc",   "YankCodeBlock",                                                                                                                                                   desc = "Yank Code Block" },
    { "<leader>yy",   '"+y',                                                                                                                                                             desc = "Yank to clipboard" },

    { "<leader>vpe",  Pymol_visual_xyz,                                                                                                                                                  desc = "Pymol Visual" },
    { "<leader>vpc",  Pymol_visual_xyz_convert,                                                                                                                                          desc = "Pymol Visual Convert" },
    { "<leader>vpb",  Pymol_visual_xyz_bohr,                                                                                                                                             desc = "Pymol Visual Bohr" },
    { "<leader>vpbc", Pymol_visual_xyz_bohr_convert,                                                                                                                                     desc = "Pymol Visual Bohr Convert" },
  }
}
local opts = { prefix = '<leader>', mode = "n" }
wk.add(normal_mappings, opts)
local visual_mappings = {
  {
    mode = { "v" },
    -- { "<leader>p<C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "Visual Chat New tabnew" },
    -- { "<leader>p<C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "Visual Chat New vsplit" },
    -- { "<leader>p<C-x>", ":<C-u>'<,'>GpChatNew split<cr>",  desc = "Visual Chat New split" },
    -- { "<leader>pa",     ":<C-u>'<,'>GpAppend<cr>",         desc = "Visual Append (after)" },
    -- { "<leader>pb",     ":<C-u>'<,'>GpPrepend<cr>",        desc = "Visual Prepend (before)" },
    -- { "<leader>pc",     ":<C-u>'<,'>GpChatNew<cr>",        desc = "Visual Chat New" },
    -- { "<leader>pg",     group = "generate into new .." },
    -- { "<leader>pge",    ":<C-u>'<,'>GpEnew<cr>",           desc = "Visual GpEnew" },
    -- { "<leader>pgn",    ":<C-u>'<,'>GpNew<cr>",            desc = "Visual GpNew" },
    -- { "<leader>pgp",    ":<C-u>'<,'>GpPopup<cr>",          desc = "Visual Popup" },
    -- { "<leader>pgt",    ":<C-u>'<,'>GpTabnew<cr>",         desc = "Visual GpTabnew" },
    -- { "<leader>pgv",    ":<C-u>'<,'>GpVnew<cr>",           desc = "Visual GpVnew" },
    -- { "<leader>pi",     ":<C-u>'<,'>GpImplement<cr>",      desc = "Implement selection" },
    -- { "<leader>pn",     "<cmd>GpNextAgent<cr>",            desc = "Next Agent" },
    -- { "<leader>pp",     ":<C-u>'<,'>GpChatPaste<cr>",      desc = "Visual Chat Paste" },
    -- { "<leader>pr",     ":<C-u>'<,'>GpRewrite<cr>",        desc = "Visual Rewrite" },
    -- { "<leader>ps",     "<cmd>GpStop<cr>",                 desc = "GpStop" },
    -- { "<leader>pt",     ":<C-u>'<,'>GpChatToggle<cr>",     desc = "Visual Toggle Chat" },
    -- { "<leader>px",     ":<C-u>'<,'>GpContext<cr>",        desc = "Visual GpContext" },
    { "<leader>t",    group = "LaTex" },
    { "<leader>tc",   ":w !wc -w<CR>",               desc = "Word Count" },
    { "<leader>tr",   Round_number,                  desc = "Round Number" },
    { "<leader>vpe",  Pymol_visual_xyz,              desc = "Pymol Visual" },
    { "<leader>vpc",  Pymol_visual_xyz_convert,      desc = "Pymol Visual Convert" },
    { "<leader>vpb",  Pymol_visual_xyz_bohr,         desc = "Pymol Visual Bohr" },
    { "<leader>vpbc", Pymol_visual_xyz_bohr_convert, desc = "Pymol Visual Bohr Convert" },
  },
}

local opts_v = { prefix = '<leader>', mode = 'v' }
wk.add(visual_mappings, opts_v)

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- null_ls.builtins.formatting.stylua,
    -- null_ls.builtins.diagnostics.eslint,
    -- null_ls.builtins.formatting.black,
    null_ls.builtins.completion.spell,
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.ruff,
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
