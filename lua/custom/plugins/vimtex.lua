return {
  "lervag/vimtex",
  init = function()
    -- vim.g.vimtex_view_method = 'zathura'
    -- vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_general_viewer = 'okular'
    vim.cmd [[
      let g:vimtex_quickfix_open_on_warning = 0
    ]]
    -- vim.g.vimtex_env_change_autofill = 1
    vim.g.vimtex_format_enabled = 1
    -- vim.api.nvim_set_keymap('x', 'tss', ':<C-u>call vimtex#cmd#run_func("vimtex-env-surround-visual", visualmode())<CR>',
      -- { noremap = true, silent = true })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.tex",
      command = "silent VimtexCompileSS",
      desc = "Compiles Latex"
    })
    -- vim.g.vimtex_compiler_method = 'latexmk'
    function fileName()
      local file = vim.fn.expand('%:t:r')
      return file
    end

    vim.g.vimtex_compiler_generic = {
      command = "pdflatex",
      -- hooks = {fileName()},
    }
    -- vim.g.vimtex_compiler_method = 'generic'
    vim.g.vimtex_compiler_method = 'arara'
  end
}
