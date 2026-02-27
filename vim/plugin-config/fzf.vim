"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LeaderF 模糊搜索配置
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 显示图标
let g:Lf_ShowDevIcons = 1

let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
" popup mode
let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewInPopup = 1
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2", 'font': "DejaVu Sans Mono for Powerline" }
let g:Lf_PreviewResult = { 'Function': 0, 'BufTag': 0 }

let g:Lf_ShortcutF = "ff"
noremap fu :<C-U><C-R>=printf("Leaderf function %s", "")<CR><CR>
noremap fb :<C-U><C-R>=printf("Leaderf buffer %s", "")<CR><CR>
noremap fm :<C-U><C-R>=printf("Leaderf mru %s", "")<CR><CR>
noremap ft :<C-U><C-R>=printf("Leaderf bufTag %s", "")<CR><CR>
noremap fl :<C-U><C-R>=printf("Leaderf line %s", "")<CR><CR>
noremap fr :<C-U><C-R>=printf("Leaderf rg %s", "")<CR><CR>
noremap fc :<C-U><C-R>=printf("Leaderf colorscheme %s", "")<CR><CR>
