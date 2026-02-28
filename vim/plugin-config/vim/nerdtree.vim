"""""""""""""""""""""""""
"      目录树插件       "
"""""""""""""""""""""""""
"NerdTree 快捷键配置
nmap tt :NERDTreeToggle<CR>
let     NERDTreeHighlightCursorline = 1 "高亮当前行
let     NERDTreeShowLineNumbers     = 1 "显示行号
let     NERDTreeMinimalUI=1
" 当进入 NERDTree 时，自定义快捷键
function! NERDTreeMyConfig()
    " 映射 l 为展开/打开文件 (原本是 o)
    nmap <buffer> l o
    " 映射 h 为收起目录 (原本是 x)
    nmap <buffer> h x
endfunction

augroup nerdtree_custom
    autocmd!
    " 仅在文件类型为 nerdtree 时生效
    autocmd FileType nerdtree call NERDTreeMyConfig()
augroup END
