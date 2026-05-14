" DEPRECATED: Neovim config has moved to config/nvim/ (lazy.nvim + Lua).
" This file is kept for vanilla vim fallback only.
"""""""""""""""""""""""""""""""""""""""""""""""""
" Default vim directory : $HOME/.vim
"
let vimDir = '$HOME/.vim'
if !isdirectory(vimDir)
    call system('mkdir ' . vimDir)
endif
let &runtimepath.=','.vimDir

" Set Undo Directory
if has('persistent_undo')
    let myUndoDir = expand(vimDir . '/undodir')
    if !isdirectory(myUndoDir)
        call system('mkdir ' . myUndoDir)
    endif
    let &undodir = myUndoDir
    set undofile
endif

" Load vim settings
let configLocation = '$HOME/.devsetting/config'

let pluginVim = expand(configLocation . '/plugin.vim')
if !empty(glob(pluginVim))
    exec ':source ' . pluginVim
endif

if has('nvim')
    nnoremap <silent> <leader>c :botright vsp <BAR> vertical resize 80 <BAR> se nonu <BAR> terminal claude<CR>i
    tnoremap <Esc> <C-\><C-n>
endif
