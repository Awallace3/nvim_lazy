return {
        'vimwiki/vimwiki',
        config = function()
            vim.g.vimwiki_list = {
                {
                    path = '~/vimwiki',
                    template_path = 'default',
                    template_default = 'default',
                    css_name = '/Users/austinwallace/vimwiki/style.css',
                    syntax = 'markdown',
                    ext = '.md',
                    path_html = '~/vimwiki',
                    custom_wiki2html = 'vimwiki_markdown',
                    template_ext = '.tpl'
                }
            }
            vim.g.vimwiki_ext2syntax = {
                ['.md'] = 'markdown'
            }
        end
}
