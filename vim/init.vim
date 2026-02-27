" 自动安装 vim-plug（如果不存在）
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo ' . data_dir . '/autoload/plug.vim --create-dirs ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif



" 通用基础配置
source ~/.vim/common.vim

" vim-plug 插件列表（可共用同一插件目录）
call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" ... 其他 Neovim 插件
call plug#end()

" 加载插件独立配置（通用部分 + Neovim 专用）
runtime! plugin-config/common/*.vim
runtime! plugin-config/nvim/*.vim
