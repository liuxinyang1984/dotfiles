"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 基础设置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 去除 VI 兼容性
set nocompatible

" 自动语法高亮
syntax on

" 增加渲染时间，解决大文件不高亮
set redrawtime=20000

" 显示行号
set number

" 突出显示当前行
set cursorline

" 设置一个 TAB 为 4 个空格
set tabstop=4
set shiftwidth=4
set expandtab
set wildmenu

" 显示第 80 列参考线
set colorcolumn=80
highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

" 设置 Leader 为空格
let mapleader="\<space>"

" 防止识别为 superhtml
autocmd BufRead,BufNewFile *.html set filetype=html

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 光标移动与窗口操作
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 插入模式下移动光标
imap <c-h> <left>
imap <c-j> <down>
imap <c-k> <up>
imap <c-l> <right>

" 切换 Tab 标签
nmap tn  :tabe<CR>
nmap th  :tabp<CR>
nmap tk  :-tabmove<CR>
nmap tj  :+tabmove<CR>
nmap tl  :tabn<CR>

" Shift 跨行移动（5行）
nmap J 5j
nmap K 5k
vmap J 5j
vmap K 5k

" 插入模式下删除行
imap <c-d> <ESC>ddi
imap <c-D> <ESC>Di


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 文件保存与退出
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

map <c-q> :q<CR>
imap <c-q> <ESC>:q<CR>
map <c-s> :w<CR>
imap <c-s> <ESC>:w<CR>
" imap <c-r> <ESC>:source ~/.vimrc<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 窗口分屏
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map s :none
map sl :set splitright<CR>:vsplit<CR>
map sh :set nosplitright<CR>:vsplit<CR>
map sj :set splitbelow<CR>:split<CR>
map sk :set nosplitbelow<CR>:split<CR>


"切换分屏
map <a-h> <c-w>h
map wh    <c-w>h
map <a-j> <c-w>j
map wj    <c-w>j
map <a-k> <c-w>k
map wk    <c-w>k
map <a-l> <c-w>l
map wl    <c-w>l


"改变分屏大小
map <a-H>   :vertical resize -5<CR>
map <a-J>   :resize +5<CR>
map <a-K>   :resize -5<CR>
map <a-L>   :vertical resize +5<CR>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 主题设置 - gruvbox
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 启用真彩色支持（现代终端需要）
if has("termguicolors")
    set termguicolors
endif

" 设置背景模式（dark/light）
set background=dark
"set background=light



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 插入日期
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab ddd <c-r>=strftime("%Y-%m-%d")<cr>
iab dddd <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>
inoreabbrev addd <C-r>=printf("@author\tMr.Cookie\n@date\t%s\n/\n", strftime("%Y-%m-%d"))<CR>
