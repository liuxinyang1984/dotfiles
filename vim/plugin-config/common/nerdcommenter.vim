"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDCommenter 快速注释
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype plugin on
" 默认情况下，在注释分隔符后添加空格
let g:NERDSpaceDelims = 1
" 对美化的多行注释使用压缩语法（貌似没什么用）
let g:NERDCompactSexyComs = 1
" 按行对齐注释分隔符左对齐，而不是按代码缩进
" let g:NERDDefaultAlign = 'left'
" 默认情况下，将语言设置为使用其备用分隔符（忽略）
let g:NERDAltDelims_java = 1
let g:NERDCustomDelimiters = {
      \ 'html': { 'left': '<!--', 'right': '-->' },
      \ 'py': { 'left': '#' },
      \ 'sh': { 'left': '#' }
      \ }
" 允许注释和反转空行（在注释区域时很有用）
let g:NERDCommentEmptyLines = 1
" 取消注释时启用尾随空白的修剪
let g:NERDTrimTrailingWhitespace = 1
" 启用 nerdcommenttoggle 检查是否对所有选定行进行了注释
let g:NERDToggleCheckAllLines = 1

let g:NERDCreateDefaultMappings = 0
nmap <c-/> <plug>NERDCommenterToggle
vmap <c-/> <plug>NERDCommenterToggle
imap <c-/> <esc><plug>NERDCommenterToggle
