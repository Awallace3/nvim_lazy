return {
  "lervag/vimtex",
  config = function()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_general_viewer = 'okular'
    vim.cmd [[
  let g:vimtex_quickfix_open_on_warning = 0
  ]]
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.tex",
      command = "silent VimtexCompileSS",
      desc = "Compiles Latex"
    })
    vim.g.vimtex_compiler_method = 'latexmk'
  end
}
