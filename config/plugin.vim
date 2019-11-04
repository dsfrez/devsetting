"""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins - powered by Vim-Plug
"
" Get Vim-Plug ----------------------------------
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

call plug#begin('~/.vim/plugged')

" Appearance ------------------------------------
" statusbar : vim-airline
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
" colorschemes
Plug 'rafi/awesome-vim-colorschemes'
" Highlight several words
Plug 'vim-scripts/Mark--Karkat'
" Seamless navigation with TMUX
Plug 'christoomey/vim-tmux-navigator'
" fix 'autoread' bug in TMUX
Plug 'tmux-plugins/vim-tmux-focus-events'
" dim inactive windows
Plug 'blueyed/vim-diminactive'

" Util ------------------------------------------
" Async run (TODO: check NeoVim or Vim8)
" - https://github.com/skywind3000/asyncrun.vim/wiki/Better-way-for-C-and-Cpp-development-in-Vim-8
Plug 'skywind3000/asyncrun.vim'

" Vim org mode - based on Emacs’ Org-Mode
"Plug 'jceb/vim-orgmode'

" Text filtering and alignment
Plug 'godlygeek/tabular'

" UML - http://plantuml.com
" TODO: sudo zypper install java
"       https://gitlab.com/graphviz/graphviz.git
Plug 'scrooloose/vim-slumlord'
Plug 'aklt/plantuml-syntax'

" git with vim - Fugitive, gitgutter
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify' "Plug 'airblade/vim-gitgutter'

" Load cscope.out
Plug 'vim-scripts/autoload_cscope.vim'

" file explorer - NERD tree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
" file searcher - ctrlp / FZF
if $DEVSETTING_TYPE == "Cygwin" || $DEVSETTING_TYPE == "MinGw"
    Plug 'kien/ctrlp.vim'
else
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
endif

" Enhanced C++ highlight
"Plug 'octol/vim-cpp-enhanced-highlight'

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

" Testing... ------------------------------------
Plug 'skywind3000/quickmenu.vim'

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
    "nnoremap <silent> <F1> :set paste!<CR>
    nnoremap <silent> <F1> :call quickmenu#toggle(0)<CR>

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
    " open buffer list (with FZF)
    nnoremap <silent> <C-b> :Buffers<CR>
    " advanced search (with FZF)
    nnoremap <silent> <C-f> :Lines<CR>

    " set build command for vim
    "nnoremap <silent> <F5> :! build_cmd_for_vim.sh<CR>
    " open file explorer
    nnoremap <silent> <F5> :NERDTreeToggle<CR>
    " open file explorer at current folder
    nnoremap <silent> <C-F5> :NERDTreeFind<CR>

    " switch to .h <-> .cc => TODO: implement this feature with FZF
    nnoremap <silent> <F8> :e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>
    " Highlight Word
    nnoremap <silent> <S-F8> :call MarkCurrentText()<CR>

    " open source explorer (definition) - TODO: remove this plugin :(
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

    " Inverse Tab - TODO: remove this ...
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
set cursorcolumn                            " highlight cursor column position
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
"set foldmethod=syntax
set foldmethod=manual
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
        exec ':set tags=' . tagsLocation
    endif
endfunction
call InitCtagLocation()

" override ctags command
nnoremap <silent><C-]> :ts <C-R>=expand("<cword>")<CR><CR>
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

"let g:cpp_class_scope_highlight = 1
"let g:cpp_member_variable_highlight = 1
"let g:cpp_class_decl_highlight = 1
"let g:cpp_experimental_template_highlight = 1
"let g:cpp_concepts_highlight = 1
"
let g:asyncrun_open = 12
let g:asyncrun_bell = 1

let g:signify_realtime = 1

function! AsyncBlame() range
    execute 'AsyncRun git blame -L ' . a:firstline . ',' . a:lastline . ' %'
endfunction
vnoremap b                 :call AsyncBlame()<CR>

nnoremap <leader>s         :Ag <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>S         :Ag <C-R>=expand("<cWORD>")<CR><CR>

" Show Shell Command in vim
command! -complete=shellcmd -nargs=+ S call s:RunShellCommand(<q-args>)
function! s:RunShellCommand(cmdline)
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(1, a:cmdline)
  execute '$read !'. expanded_cmdline
  setlocal nomodifiable
endfunction

" TODO: handle if current buffer is empty
" TODO: suppress error E173: more files to edit
function! s:openFilesInGit(cmdline)
    let shellcmd_result = system("git show --name-only --oneline " . expand(a:cmdline))
    if (shellcmd_result =~ "fatal: ambiguous argument.")
        echo "[Error] current git doesn't contains commit - " . a:cmdline
        return
    endif
    let files = join(split(shellcmd_result, '\n')[1:], ' ')
    exec ':args ' . files
endfunction
command! -nargs=* -complete=shellcmd OpenFilesInGit call s:openFilesInGit(<q-args>)

function! s:openFilesInGitDiff(cmdline)
    let shellcmd_result = system("git diff --name-only --oneline " . expand(a:cmdline))
    let files = join(split(shellcmd_result, '\n'), ' ')
    exec ':args ' . files
endfunction
command! -nargs=* -complete=shellcmd OpenFilesInGitDiff call s:openFilesInGitDiff(<q-args>)

" Clear all the items
call g:quickmenu#reset()

" Enable cursorline (:) and cmdline help (H)
let g:quickmenu_options = "HL"

call g:quickmenu#append("# Navigation", '')
call g:quickmenu#append("File Explorer", 'NERDTreeToggle', "Powered by NerdTree - F5")
call g:quickmenu#append("File Explorer - current location", 'NERDTreeFind', "Powered by NerdTree - Ctrl-F5")
call g:quickmenu#append("Open All Files in HEAD", 'OpenFilesInGit', "Open all files in 'git show --nameonly'")
call g:quickmenu#append("Open All Files in Diff", 'OpenFilesInGitDiff', "Open all files in 'git show --nameonly'")

call g:quickmenu#append("# Vim Preferences", '')
call g:quickmenu#append("Toggle Paste", 'set paste!', "Set/Unset PASTE mode to avoid unintended indentation")
call g:quickmenu#append("Toggle Cursorcolumn", 'set cursorcolumn!', "Show/Hide cursor column")
call g:quickmenu#append("Toggle Word wrap", 'set wrap!', "Set/Unset word wrap")
