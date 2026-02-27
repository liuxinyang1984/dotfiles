"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TableMode 开关表格模式
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

noremap <LEADER>tm :TableModeToggle<CR>
noremap <LEADER>tr :TableModeRealign<CR>
autocmd VimEnter * unmap <Space>tt
noremap <LEADER>ti :TableModeTableize<CR>
