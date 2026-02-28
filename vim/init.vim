let s:plug_dir = has('nvim') ? stdpath('data') . '/site/autoload' : '~/.vim/autoload'
let s:plug_file = s:plug_dir . '/plug.vim'
if empty(glob(s:plug_file))
  echo "vim-plug 未安装，正在下载..."
  " 确保目录存在
  call mkdir(s:plug_dir, 'p')
  " 执行下载（暂时不 silent，以便查看错误）
  execute '!curl -fLo ' . s:plug_file . ' ' .
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if empty(glob(s:plug_file))
    echoerr "vim-plug 下载失败，请检查网络或手动安装。"
  else
    echo "vim-plug 下载成功！"
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif


" vim-plug 插件列表（可共用同一插件目录）
call plug#begin('~/.vim/plugged')
"gruvbox主题
Plug 'morhetz/gruvbox'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"模糊搜索
Plug 'yggdroot/leaderf'

"代码块选择
Plug 'gcmt/wildfire.vim'

"符号包围
"S  将选中的块添加符号包围 例:S'    将选中块用单引号包围
"cs 将选中的块包围符号更换 例:cs'"  将单引号更换为双引号
Plug 'tpope/vim-surround'

"可视化缩进
Plug 'Yggdroot/indentLine'

"忘记sudo vim 可以:sudowrite或者:sw
Plug 'lambdalisue/suda.vim'

"快速注释
Plug 'scrooloose/nerdcommenter' 


" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install'  }
Plug 'joker1007/vim-markdown-quote-syntax'
Plug 'dhruvasagar/vim-table-mode'

" terminal
Plug 'akinsho/toggleterm.nvim', { 'tag' : '*' }

Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" 加载插件独立配置（通用部分 + Neovim 专用）
runtime! common.vim
runtime! plugin-config/common/*.vim
runtime! plugin-config/nvim/*.vim


