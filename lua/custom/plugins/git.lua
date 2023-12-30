return {
  'rhysd/conflict-marker.vim',
  config = function()
    vim.g.conflict_marker_highlight_group = 'DiffChange'
    vim.api.nvim_command([[
        highlight ConflictMarkerBegin guibg=#2f7366
        highlight ConflictMarkerOurs guibg=#2e5049
        highlight ConflictMarkerTheirs guibg=#344f69
        highlight ConflictMarkerEnd guibg=#2f628e
        highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
    ]])
  end,
}
