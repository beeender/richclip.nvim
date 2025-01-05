set rtp^=./vendor/plenary.nvim/
set rtp^=../

runtime plugin/plenary.vim

lua require('plenary.busted')

" configuring the plugin
runtime .
" lua require('my_awesome_plugin').setup({ name = 'Jane Doe' })
