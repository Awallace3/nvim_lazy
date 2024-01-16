-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Set word wrap
vim.o.wrap = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'
vim.o.clipboard = 'unnamedplus'
-- vim.o.clipboard = ''

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.o.scrolloff = 10

-- Path for gf
vim.opt_local.suffixesadd:prepend('.lua')
vim.opt_local.suffixesadd:prepend('init.lua')
vim.opt_local.path:prepend(vim.fn.stdpath('config') .. '/lua')
vim.g.python3_host_prog = vim.fn.expand("~/miniconda3/envs/nvim/bin/python")

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "markdown" },
  callback = function()
    vim.api.nvim_command('filetype plugin on')
    vim.api.nvim_command('setlocal spell spelllang=en_us')
    vim.api.nvim_command('set spellsuggest+=10')
  end
})

function GetWordUnderCursor()
  local _, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local start_col, end_col = col + 1, col + 1

  while start_col > 1 and line:sub(start_col - 1, start_col - 1):match("%w") do
    start_col = start_col - 1
  end

  while end_col <= #line and line:sub(end_col, end_col):match("%w") do
    end_col = end_col + 1
  end
  line = line:sub(start_col, end_col - 1)
  return line
end

function GetRefsBibFileName()
  local regex = 'bibliography{\\w*}'
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local match = vim.fn.matchstr(line, regex)
    if match ~= "" then
      -- Extracting filename
      local filename = match:match("{(.-)}")
      if filename:sub(-4) ~= ".bib" then
        filename = filename .. ".bib"
      end
      print("Bibliography found: " .. filename)
      return filename
    end
  end
  print("No bibliography found in file.")
  return nil
end

function SearchTexCitation()
  local bib_filename = GetRefsBibFileName()
  if bib_filename == nil then
    print("No bibliography found in file.")
    return nil
  end
  local word = GetWordUnderCursor()
  if word == nil then
    print("No word found under cursor.")
    return nil
  end
  print("Searching for citation: " .. word)

  local path_to_bib = "./" .. bib_filename -- Update with actual path
  local lines = vim.fn.readfile(path_to_bib)
  local citation_pattern = "@" .. ".*{" .. word .. ","
  local title_pattern = "title%s*=%s*{.-},"

  -- check if lines is nil before iterating
  if lines == nil then
    print("No lines found in bib file.")
    return nil
  end
  local start_title_search = false
  for _, line in ipairs(lines) do
    if line:match(citation_pattern) then
      start_title_search = true
    end
    if start_title_search then
      if line:match(title_pattern) then
        print("Citation found: " .. line)
        HandleSearchCitationOrURL(line)
        return
      end
    end
  end
  print("Citation not found.")
end

function HandleSearchCitationOrURL(line)
  local uri = vim.fn.matchstr(vim.fn.getline('.'), '[a-z]*:\\/\\/[^ >,;()]*')
  -- uri = vim.fn.shellescape(uri, 1)
  local filetype = vim.bo.filetype
  if uri ~= "" then
    print(uri)
    vim.fn.system('open ' .. uri)
  elseif filetype == "bib" or filetype == 'tex' then
    -- check if 'title' is in line
    if line == nil then
      CitationTitle = vim.fn.matchstr(vim.fn.getline('.'), '{\\w*.*}')
    else
      CitationTitle = vim.fn.matchstr(line, '{\\w*.*}')
    end
    if CitationTitle == nil or CitationTitle == "" then
      print("No title found in line for bib file.")
      return
    else
      CitationTitle = string.sub(CitationTitle, 2, -2)
      CitationTitle = vim.fn.substitute(CitationTitle, ' ', '+', 'g')
      print("Title found: " .. CitationTitle)
      local open_command = 'open https://scholar.google.com/scholar?q=' .. CitationTitle
      print(open_command)
      vim.fn.system(open_command)
    end
  else
    print("No URI found in line.")
  end
end

vim.api.nvim_set_keymap('n', 'gX', ':lua SearchTexCitation()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gt', ':lua GetWordUnderCursor()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'gx', ':lua HandleSearchCitationOrURL()<CR>', { noremap = true, silent = true })
-- vim: ts=2 sts=2 sw=2 et
