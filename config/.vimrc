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

let devsettingConfig = '$HOME/.devsetting/config'

let devsettingConfigPlug = expand(devsettingConfig . '/plugin.vim')
if !empty(glob(devsettingConfigPlug))
    exec ':source ' . devsettingConfigPlug
endif
