return {
  "chris-lep/checkbox.nvim",
  lazy = false,
  config = function()
	-- keymap <leader>mm to cycle state
	vim.api.nvim_set_keymap("n", "<leader>mm", ":lua require('checkbox').cycle()<CR>", { noremap = true, silent = true })
	end,
}
