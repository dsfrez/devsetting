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

"""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins - powered by Vim-Plug
"
" Get Vim-Plug
let plugVimPath = expand(vimDir . '/autoload/plug.vim')
if !filereadable(plugVimPath)
    echo expand(plugVimPath . ' doesnt exist. Downloading Vim-Plug(https://github.com/junegunn/vim-plug)')
    let plugVimCmd = expand('curl -fLo ' . plugVimPath . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
    call system(plugVimCmd)
    exec ':so ' . plugVimPath
endif
" Set Python3 Environment - some plugins need python
if filereadable(substitute(system('which python3'), '\n\+$', '', ''))
    let g:python3_host_prog = substitute(system('which python3'), '\n\+$', '', '')
endif

" Plugin Lists
call plug#begin('~/.vim/plugged')

" colorschemes
Plug 'rafi/awesome-vim-colorschemes'
" statusbar : vim-airline
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
" Highlight several words
Plug 'vim-scripts/Mark--Karkat'
" Seamless navigation with TMUX
Plug 'christoomey/vim-tmux-navigator'

" Text filtering and alignment
Plug 'godlygeek/tabular'

" fix 'autoread' bug in TMUX
Plug 'tmux-plugins/vim-tmux-focus-events'

" dim inactive windows
Plug 'blueyed/vim-diminactive'

" git with vim - Fugitive, gitgutter
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" Load cscope.out
Plug 'vim-scripts/autoload_cscope.vim'

" file explorer - NERD tree
Plug 'scrooloose/nerdtree'
" file searcher - ctrlp / FZF
if $DEVSETTING_TYPE == "Cygwin" || $DEVSETTING_TYPE == "MinGw"
    Plug 'kien/ctrlp.vim'
else
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
endif

" source explorer with ctags - Src Explorer
Plug 'wesleyche/srcexpl', { 'on': 'SrcExplToggle' }
" source info - Tagbar
Plug 'majutsushi/tagbar'

" Asynchronous linting/fixing for Vim
Plug 'w0rp/ale'

" Auto Complete - YouCompleteMe (requires Python >= 2.7.1 or >= 3.4)
let g:myAutocompletePlugin = 'Deoplete'

function! BuildYCMWithClang(info)
    " - status: 'installed', 'updated', or 'unchanged'
    " - force:  set on PlugInstall! or PlugUpdate!
    if a:info.status == 'installed' || a:info.force
        !python3 ./install.py --clang-completer
    endif
endfunction

" TODO: incomplete - set up environment for YCM
" require libclang, cmake
function! s:useYouCompleteMe()
    if g:myAutocompletePlugin != 'YCM'
        return
    endif
    Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCMWithClang') }
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable'}
endfunction

function! s:useDeoplete()
    if g:myAutocompletePlugin != 'Deoplete'
        return
    endif

    if has('nvim')
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

        " For deoplete autocomplete
        Plug 'zchee/deoplete-jedi'
        Plug 'Shougo/neco-syntax'
        Plug 'Shougo/neco-vim'
        Plug 'davidhalter/jedi-vim'
        "Plug 'zchee/deoplete-zsh'
    endif
endfunction

call s:useYouCompleteMe()
call s:useDeoplete()

" for quick fix??
Plug 'ronakg/quickr-preview.vim'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""
" Custom Key Mapping
"
function! CloseBuffer()
    if len(getbufinfo({'buflisted':1})) == 1
        exec ':bd'
    else
        if buflisted(bufnr("#"))
            exec ':b ' . bufnr("#") . '| bd ' . bufnr("%")
        else
            if buflisted(bufnr("%"))
                exec ':bprevious!' . '| bd ' . bufnr("%")
            else
                exec ':bprevious!'
            endif
        endif
    endif
endfunction

function! FZFWithPrjFile()
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    if filereadable(expand(root . '/cscope.files'))
        exec ':lcd ' . root
    endif
    exec ':FZF'
endfunction

" If you want to mark a word only, please use <leader>m
function! MarkCurrentText()
    let currWord = expand('<cword>')
    exec ':Mark ' . currWord
endfunction

function! s:setFunctionKeyMap()
    " to avoid auto indent while pasting something
    "nnoremap <silent> <C-F1> :set paste!<CR>

    " close current buffer and move to previous buffer
    nnoremap <silent> <F1> :call CloseBuffer()<CR>
    " move to previous opened buffer
    nnoremap <silent> <F2> :b #<CR>
    " move to previous buffer
    nnoremap <silent> <F3> :bprevious!<CR>
    " move to next buffer
    nnoremap <silent> <F4> :bnext!<CR>
    " close current buffer and move to previous buffer
    nnoremap <silent> <C-F4> :call CloseBuffer()<CR>

    " open new buffer
    nnoremap <silent> <C-N> :enew<CR>
    " open file (with FZF)
    if $DEVSETTING_TYPE == "Cygwin" || $DEVSETTING_TYPE == "MinGw"
        let g:ctrlp_map = '<c-o>'
    else
        nnoremap <silent> <C-O> :call FZFWithPrjFile()<CR>
    endif


    " set build command for vim
    nnoremap <silent> <F5> :! build_cmd_for_vim.sh<CR>

    " switch to .h <-> .cc => TODO: implement this feature with FZF
    nnoremap <silent> <F8> :e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>
    " Highlight Word
    nnoremap <silent> <S-F8> :call MarkCurrentText()<CR>

    " toggle cursorcolumn - show current cursor postion
    nnoremap <silent> <F9> :set cursorcolumn!<CR>

    " open file explorer
    nnoremap <silent> <F10> :NERDTreeToggle<CR>
    " open file explorer at current folder
    nnoremap <silent> <C-F10> :NERDTreeFind<CR>
    " open source explorer (definition)
    nnoremap <silent> <F11> :SrcExplToggle<CR>
    " open tag information
    nnoremap <silent> <F12> :TagbarToggle<CR>
endfunction

function! s:setEditorKeyMap()
    " Copy and Paste
    vmap <C-c> "+yi
    vmap <C-x> "+c
    vmap <C-v> c<ESC>"+p
    imap <C-v> <ESC>"+pa

    " Inverse Tab
    nnoremap <S-Tab> <<
    inoremap <S-Tab> <C-d>

    " Move Cursor
    nmap <C-Home> gg
    nmap <C-End> :%<CR>
endfunction

function! s:setWindowKeyMap()
    if has('nvim')
        let g:terminal_scrollback_buffer_size = 100000
        nnoremap <silent> <A-t> :bel sp <BAR> resize 15 <BAR> se nonu <BAR> terminal<CR>i
        tnoremap <C-h> <C-\><C-n> :TmuxNavigateLeft<CR>
        tnoremap <C-j> <C-\><C-n> :TmuxNavigateDown<CR>
        tnoremap <C-k> <C-\><C-n> :TmuxNavigateUp<CR>
        tnoremap <C-l> <C-\><C-n> :TmuxNavigateRight<CR>

        " sometimes ctrl-keymap doesn't work ..
        tnoremap <A-h> <C-\><C-n><C-w>h
        tnoremap <A-j> <C-\><C-n><C-w>j
        tnoremap <A-k> <C-\><C-n><C-w>k
        tnoremap <A-l> <C-\><C-n><C-w>l
        tnoremap <A-w> <C-\><C-n><C-w>w
    endif
    nnoremap <A-h> <C-w>h
    nnoremap <A-j> <C-w>j
    nnoremap <A-k> <C-w>k
    nnoremap <A-l> <C-w>l
    nnoremap <A-w> <C-w>w
endfunction

" if you don't want to use below key mapping, please comment out
call s:setFunctionKeyMap()
call s:setEditorKeyMap()
call s:setWindowKeyMap()

" TODO: remaining items ...
"let mapleader = ","
"map <F3> [{v]}zf   " file folding
"map <F4> zo        " file unfolding

"""""""""""""""""""""""""""""""""""""""""""""""""
" General Settings
" http://vimdoc.sourceforge.net/htmldoc/options.html
"
"" Text Encoding """"""""""""""""""""""""""""""""
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
    set encoding=utf-8
    set fileencodings=utf-8,cp949
endif
scriptencoding utf-8

"" Indent & Tab """""""""""""""""""""""""""""""""
set autoindent                              " auto indent
set smartindent                             " smart indent
set cindent                                 " c style indent
set cinoptions=g0,:0                        " no indentation for public: private: protectd: case:
set cinkeys-=0#                             " no pre-indentation for macros

set expandtab                               " tab to space ('et')
set shiftwidth=4                            " indent tab size
set softtabstop=4                           " makes the spaces feel like real tabs
set tabstop=4                               " tab size

"" Search """""""""""""""""""""""""""""""""""""""
set hlsearch                                " highlight searched string
set ignorecase                              " ignore upper/lower case ('ic')
set incsearch                               " incremental search ('is')

"" Information """"""""""""""""""""""""""""""""""
set title                                   " show current file name to title bar
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

"" Preferences """"""""""""""""""""""""""""""""""
set autoread                                " automatic refresh
set backspace=indent,eol,start              " make backspace work like most other programs
set cursorline                              " highlight current line
set noswapfile                              " don't make .swp file
set novisualbell                            " no visual bell (alert)
set ruler                                   " show cursor location
set number                                  " show line number
set showmatch                               " show matching parenthesis
set laststatus=2                            " show status bar
set mouse=a                                 " use mouse
"set nojoinspaces

"" Buffer """""""""""""""""""""""""""""""""""""""
set hidden
"set complete=.,i,b
"set autowrite
"set autochdir

"" Appearance """""""""""""""""""""""""""""""""""
" Syntax
if &t_Co > 2 || has("gui_running") || has("syntax")
    syntax on
endif

" Theme - compatible with tmux
if &term == "xterm"
    set t_Co=256
endif
set background=dark

" Dim inactive windows
let g:diminactive_enable_focus = 0 " don't use vim-tmux focus event
function! TweakForDimInactiveWindow() abort
    " becase there is a bug in vim-tmux focus event.
    " I'll manage bgcolor in .tmux.conf
    highlight Normal        ctermbg=NONE
    highlight ColorColumn   ctermbg=236
endfunction

function! s:inverseDimColor()
    augroup MyColors
        autocmd!
        autocmd ColorScheme * call TweakForDimInactiveWindow()
    augroup END
endfunction
" if you want to use original colorscheme please comment out below function call
call s:inverseDimColor()

colorscheme apprentice " should be called after autocmd

" Whitespace & EndingSpace Highlight
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
set list listchars=tab:»·,trail:·,extends:$,nbsp:=

"" Development Environment """"""""""""""""""""""
"set foldmethod=marker
set foldmethod=syntax
"set foldnestmax=1
set foldlevel=20
set foldlevelstart=20

"" Load Personal Environment """""""""""""""""""
if !empty(glob("~/.vimrc_alias"))
    source ~/.vimrc_alias
endif

"" External & Plugin Setting """"""""""""""""""""
" set tmux pane name
let current_shell = system("echo $(basename $SHELL)")
let current_tmux_window = system("tmux display-message -p '#W'")
if current_tmux_window == current_shell
    autocmd BufReadPost,FileReadPost,BufNewFile * call system("tmux rename-window " . expand("%:t"))
    autocmd VimLeave * call system("tmux rename-window " . expand(current_shell))
endif

" for vim-airline
let g:airline_theme='angr'
let g:airline#extensions#tabline#enabled = 1                " turn on buffer list
let g:airline#extensions#tabline#fnamemod = ':t'            " print file name only
let g:airline#extensions#tabline#buffer_nr_show = 1         " show buffer number
let g:airline#extensions#tabline#buffer_nr_format = '%s:'   " buffer number format
let g:airline#extensions#tabline#buffer_idx_mode = 1        " show index of buffer
let g:airline_powerline_fonts = 1

" set unicode symbols for vim
if !has('nvim')
    set guifont=Dejavu\ Sans\ Mono\ for\ Powerline

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    let g:airline_left_sep = '»'
    let g:airline_left_sep = '▶'
    let g:airline_right_sep = '«'
    let g:airline_right_sep = '◀'
    let g:airline_symbols.crypt = '🔒'
    let g:airline_symbols.linenr = '☰'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '␤'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.maxlinenr = ''
    let g:airline_symbols.maxlinenr = '㏑'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.paste = 'Þ'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.spell = 'Ꞩ'
    let g:airline_symbols.notexists = '∄'
    let g:airline_symbols.whitespace = 'Ξ'

    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = '☰'
    let g:airline_symbols.maxlinenr = ''
endif

" ctags & cscope configuration {{{
"
function! InitCtagLocation()
    let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
    let tagsLocation = expand(root . '/tags')
    if filereadable(expand(tagsLocation))
        exec ':set tags+=' . tagsLocation
    endif
endfunction
"call InitCtagLocation() - problem exsits ..

" override ctags command
nnoremap <C-]> :ts <C-R>=expand("<cword>")<CR><CR>

if has('cscope')
    " http://cscope.sourceforge.net/cscope_maps.vim
    " use both cscope and ctag for 'ctrl-]', ':ta', and 'vim -t'
    set cscopetag
    " check cscope for definition of a symbol before checking ctags: set to 1
    " if you want the reverse search order.
    set csto=0
    " don't show cscope.out loading message (by autoload_cscope.vim)
    set nocscopeverbose

    " https://stackoverflow.com/questions/24510721/cscope-result-handling-with-quickfix-window
    " 's'   symbol: find all references to the token under cursor
    nnoremap <C-\>s yiw:cs find s <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
    " 'g'   global: find global definition(s) of the token under cursor
    nnoremap <C-\>g yiw:cs find g <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
    "nnoremap <C-\>c yiw:cs find c <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
    nnoremap <C-\>i yiw:cs find i <C-R>=expand("<cword>")<CR><CR>:bd<CR>:cwindow<CR>/<C-R>0<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

    if has('quickfix')
        set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
        nnoremap <C-]>s :set cscopequickfix=s+<CR> :cs find s <C-R>=expand("<cword>")<CR><CR>
    endif
endif
" }}}

" FZF config
let g:fzf_layout = { 'down': '~30%' }

" for Source Explorer {{{
" // Set the height of Source Explorer window
let g:SrcExpl_winHeight = 12
" // Set "Enter" key to jump into the exact definition context
let g:SrcExpl_jumpKey = "<ENTER>"
" // Set "Space" key for back from the definition context
let g:SrcExpl_gobackKey = "<SPACE>"
" // Do not let the Source Explorer update the tags file when opening
" it will be processed by prjfile
let g:SrcExpl_isUpdateTags = 0

" // In order to avoid conflicts, the Source Explorer should know what plugins except
" // itself are using buffers. And you need add their buffer names into below list
" // according to the command ":buffers!"
let g:SrcExpl_pluginList = [
        \ "__Tag_List__",
        \ "_NERD_tree_",
        \ "Source_Explorer",
        \ "bash"
    \ ]
" }}}

" ----- ale -----
let g:ale_lint_on_save = 1                                  " Lint when saving a file
let g:ale_sign_error = '✖'                                  " Lint error sign
let g:ale_sign_warning = '⚠'                                " Lint warning sign
let g:ale_statusline_format =[' %d E ', ' %d W ', '']       " Status line texts
"let g:ale_linters = {'javascript': ['eslint']}              " Lint js with eslint
"let g:ale_fixers = {'javascript': ['prettier', 'eslint']}   " Fix eslint errors

function! s:ycmSetting()
    if g:myAutocompletePlugin != 'YCM'
        return
    endif

    "https://raw.githubusercontent.com/Valloric/ycmd/66030cd94299114ae316796f3cad181cac8a007c/.ycm_extra_conf.py
    let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
    let g:ycm_collect_identifiers_from_tags_files = 1
endfunction

function! s:deopleteSetting()
    if g:myAutocompletePlugin != 'Deoplete'
        return
    endif

    "----- deoplete -----
    let g:deoplete#enable_at_startup = 1
    " use tab to forward cycle
    inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
    " use tab to backward cycle
    inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

    " ----- jedi vim -----
    let g:jedi#show_call_signatures = "0"                       "jedi-vim slowdown
endfunction

call s:ycmSetting()
call s:deopleteSetting()
