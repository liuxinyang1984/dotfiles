" --- Floaterm 设置 ---
" 设置浮动窗口大小
let g:floaterm_width = 0.8
let g:floaterm_height = 0.8

" 设置终端打开的位置：'float' (浮动, 需 Vim 8.2+), 'center', 'topright' 等
" 如果你的 Vim 版本过低不支持 float，它会自动回退到普通分割窗口
let g:floaterm_position = 'center'

" 配置背景颜色（可选，让它看起来更像独立窗口）
hi Floaterm guibg=black
hi FloatermBorder guibg=orange guifg=orange

" 快捷键绑定
let g:floaterm_keymap_toggle = '<F12>'
let g:floaterm_keymap_next   = '<F11>'
let g:floaterm_keymap_prev   = '<F10>'
let g:floaterm_keymap_new    = '<F9>'

" 退出终端模式的映射（在终端里按 ESC 直接回到 Normal 模式）
tnoremap <Esc> <C-\><C-n>
" Normal 模式
nnoremap <silent> <C-\> :FloatermToggle<CR>
" Terminal 模式（在终端内部按下也能隐藏）
tnoremap <silent> <C-\> <C-\><C-n>:FloatermToggle<CR>
