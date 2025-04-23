return {
  "luk400/vim-jukit",
  ft={
    'ipynb'
  },
  config = function()
    vim.cmd[[
      let g:jukit_output_bg_color = get(g:, 'jukit_output_bg_color', '')
      "    - Optional custom background color of output split window (i.e. target window of sent code)
      let g:jukit_output_fg_color = get(g:, 'jukit_output_fg_color', '')
      "    - Optional custom foreground color of output split window (i.e. target window of sent code)
      let g:jukit_outhist_bg_color = get(g:, 'jukit_outhist_bg_color', '#090b1a')
      "    - Optional custom background color of output-history window
      let g:jukit_outhist_fg_color = get(g:, 'jukit_outhist_fg_color', 'gray')
      "    - Optional custom foreground color of output-history window
      let g:jukit_output_new_os_window = -1
      "    - If set to 1, opens output split in new os-window. Can be used to e.g. write code in one kitty-os-window on your primary monitor while sending code to the shell which is in a seperate kitty-os-window on another monitor.
      let g:jukit_outhist_new_os_window = 0
"    - Same as `g:jukit_output_new_os_window`, only for output-history-split
    ]]
  end,
}
