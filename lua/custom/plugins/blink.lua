-- return {
--   'saghen/blink.nvim',
--   optional = true,
--   opts = {
--     keymap = {
--       ['<A-y>'] = {
--         function(cmp)
--           cmp.show { providers = { 'minuet' } }
--         end,
--       },
--     },
--     sources = {
--       -- if you want to use auto-complete
--       default = { 'minuet' },
--       providers = {
--         minuet = {
--           name = 'minuet',
--           module = 'minuet.blink',
--           score_offset = 100,
--         },
--       },
--     },
--   },
return {
	'saghen/blink.nvim',
	-- dependencies = {
	-- 	"lukas-reineke/indent-blankline.nvim"
	-- },
	keys = {
		-- chartoggle
		{
			';',
			function()
				require('blink.chartoggle').toggle_char_eol(';')
			end,
			mode = { 'n', 'v' },
			desc = 'Toggle ; at eol',
		},
		{
			',',
			function()
				require('blink.chartoggle').toggle_char_eol(',')
			end,
			mode = { 'n', 'v' },
			desc = 'Toggle , at eol',
		},

		-- tree
		{ '<C-e>',     '<cmd>BlinkTree reveal<cr>', desc = 'Reveal current file in tree' },
		{ '<leader>E', '<cmd>BlinkTree toggle<cr>', desc = 'Reveal current file in tree' },
		-- { '<leader>e', '<cmd>BlinkTree toggle-focus<cr>', desc = 'Toggle file tree focus' },
	},
	-- all modules handle lazy loading internally
	lazy = false,
	opts = {
		chartoggle = { enabled = true },
		delimiters = { enabled = true },
		-- indent = {
		-- 	enabled = true,
		-- 	blocked = {
		-- 		filetypes = { 'dbout' }
		-- 	}
		-- },
		tree = { enabled = true }
	}
}
