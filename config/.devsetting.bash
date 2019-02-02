# Please input below statement in .bashrc
#
# [ -f ~/.devsetting.bash ] && source ~/.devsetting.bash

# General Preferences ##########################################################
# Path
[ -d "$HOME/.local/bin" ] && export PATH=$PATH:$HOME/.local/bin
# use 256 color
[ -n "$DISPLAY" -a "$TERM" == "xterm" ] && export TERM=xterm-256color
#[ "$TERM" == "xterm" ] && export TERM=xterm-256color

# for Windows Subsystem Linux
umask 022
# for cygwin
export CHERE_INVOKING=1
# for NeoVim
export XDG_CONFIG_HOME=$HOME/.config

# FZF Setting - https://github.com/junegunn/fzf.vim/issues/12
export PATH=$PATH:$HOME/.fzf/bin
export FZF_DEFAULT_COMMAND='GIT_ROOT=$(git rev-parse --show-toplevel);if [ -e $GIT_ROOT/cscope.files ]; then cat $GIT_ROOT/cscope.files; else find ./ -type f ; fi'
export FZF_COMPLETION_OPTS='+c -x'
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--extended-exact --bind ctrl-f:page-down,ctrl-b:page-up --color fg:252,bg:233,hl:67,fg+:252,bg+:235,hl+:121 --color info:144,prompt:161,spinner:135,pointer:135,marker:118'

# Custom Environments ##########################################################
# Path for dev_setting
DEVSETTING_DIR=$HOME/.devsetting
[ ! -d "$DEVSETTING_DIR" ] && mkdir -p $DEVSETTING_DIR/tools/bin
TOOLS_DIR=$DEVSETTING_DIR/tools
for d in $DEVSETTING_DIR/tools/*; do TOOLS_DIR="$TOOLS_DIR:$d"; done
export PATH=$PATH:$TOOLS_DIR
# use external library
export DEVSETTING_GIT=$DEVSETTING_DIR/git
export DEVSETTING_BIN=$DEVSETTING_DIR/tools/bin

# check Python3 version - this will be used by various plugins
is_valid_python3_version ()
{
    # let's use Python >= 3.5
    if [ -f "$(which python3)" ]; then
        $(which python3) -c 'import sys; print("%i" % (sys.hexversion>=0x030500F0))'
    else
        echo 0
    fi
}

# Powerline Setting
if [ -f "$(command -v powerline)" ]; then
    if [ -d $HOME/.local/lib/python2.7/site-packages/powerline ]; then
        export POWERLINE_REPO=$HOME/.local/lib/python2.7/site-packages/powerline
    elif [ -d /usr/lib/python2.7/site-packages/powerline ]; then
        export POWERLINE_REPO=/usr/lib/python2.7/site-packages/powerline
    elif [ -d /usr/local/lib/python2.7/site-packages/powerline ]; then
        export POWERLINE_REPO=/usr/local/lib/python2.7/site-packages/powerline
    fi

    if [ -f $POWERLINE_REPO/bindings/bash/powerline.sh ]; then
        export PATH=$PATH:$POWERLINE_REPO
        powerline-daemon -q
        POWERLINE_BASH_CONTINUATION=1
        POWERLINE_BASH_SELECT=1
        source $POWERLINE_REPO/bindings/bash/powerline.sh
    fi
fi

# Tmux - https://github.com/tmux/tmux.git
tmux_func()
{
    TERM=screen-256color
    if [ -f "$DEVSETTING_GIT/tmux/tmux" ]; then
        $DEVSETTING_GIT/tmux/tmux "$@"
    elif [ -f "/usr/bin/tmux" ]; then
        /usr/bin/tmux "$@"
    else
        echo "Please install tmux - https://github.com/tmux/tmux.git"
        return -1
    fi
    return 0
}
alias tmux=tmux_func

# Neovim - https://github.com/neovim/neovim/releases/tag/v0.3.1
neovim_func ()
{
    if [ -f "$DEVSETTING_BIN/nvim-0.3.1" ]; then
        nvim-0.3.1 "$@"
    elif [ -f "/usr/bin/nvim" ]; then
        /usr/bin/nvim "$@"
    elif [ -f "/usr/bin/vim" ]; then
        /usr/bin/vim "$@"
    else
        echo "Please install neovim(https://neovim.io) or vim"
        /usr/bin/vi "$@"
    fi
    return 0
}
alias vi=neovim_func

# Universal ctags - https://github.com/universal-ctags/ctags.git
ctags_func ()
{
    if [ -f "$DEVSETTING_GIT/ctags/ctags" ]; then
        $DEVSETTING_GIT/ctags/ctags "$@"
    elif [ -f "/usr/bin/ctags" ]; then
        /usr/bin/ctags "$@"
    else
        echo "Please install universal ctags(https://github.com/universal-ctags/ctags.git) or exuberant-ctags"
        return -1
    fi
    return 0
}
alias ctags=ctags_func

# The Silver Searcher (AG) - git clone https://github.com/ggreer/the_silver_searcher.git
ag_func()
{
    if [ -f "$DEVSETTING_GIT/the_silver_searcher/ag" ]; then
        $DEVSETTING_GIT/the_silver_searcher/ag "$@"
    elif [ -f "/usr/bin/ag" ]; then
        /usr/bin/ag "$@"
    else
        echo "Please install The Silver Searcher - https://github.com/ggreer/the_silver_searcher.git"
        return -1
    fi
    return 0
}
alias ag=ag_func

# Utility Functions #############################
alias u='cd ..' # TODO: enhance this function

# function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
cd_func ()
{
    local x2 the_new_dir adir index
    local -i cnt

    if [[ $1 ==  "--" ]]; then
        dirs -v
        return 0
    fi

    the_new_dir=$1
    [[ -z $1 ]] && the_new_dir=$HOME

    if [[ ${the_new_dir:0:1} == '-' ]]; then
        #
        # Extract dir N from dirs
        index=${the_new_dir:1}
        [[ -z $index ]] && index=1
        adir=$(dirs +$index)
        [[ -z $adir ]] && return 1
        the_new_dir=$adir
    fi

    #
    # '~' has to be substituted by ${HOME}
    [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

    #
    # Now change to the new dir and add to the top of the stack
    pushd "${the_new_dir}" > /dev/null
    [[ $? -ne 0 ]] && return 1
    the_new_dir=$(pwd)

    #
    # Trim down everything beyond 11th entry
    popd -n +11 2>/dev/null 1>/dev/null

    #
    # Remove any other occurence of this dir, skipping the top of the stack
    for ((cnt=1; cnt <= 10; cnt++)); do
        x2=$(dirs +${cnt} 2>/dev/null)
        [[ $? -ne 0 ]] && return 0
        [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
        if [[ "${x2}" == "${the_new_dir}" ]]; then
            popd -n +$cnt 2>/dev/null 1>/dev/null
            cnt=cnt-1
        fi
    done

    return 0
}
alias cd=cd_func

# push a commit with a reviewer (ex: gitpush TARGETBRANCH reviewer@email.com)
function gitpush() {
    git push --receive-pack="git receive-pack --reviewer $2" origin HEAD:refs/for/$1
}

# check YouCompleteMe Compatible (Python >= 3.4 && libclang)
check_YCM_compatible()
{
    if [ $(is_valid_python3_version) == 1 ] && [ -f "$(which clang)" ]; then
        echo 1
    else
        echo 0
    fi
}
