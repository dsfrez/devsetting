export SHELL=$(which zsh)

export DEVSETTING_DIR=$HOME/.devsetting

# setup fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ ! -e $DEVSETTING_DIR/antigen.zsh ]; then
    curl -k -L git.io/antigen > $DEVSETTING_DIR/antigen.zsh
fi

# antigen installation. -------------------------------------------------------
source $DEVSETTING_DIR/antigen.zsh
antigen use oh-my-zsh
#antigen theme agnoster
antigen theme ys

antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle uvaes/fzf-marks

antigen apply

#eval `dircolors $DEVSETTING_DIR/git/dircolors-solarized/dircolors.256dark`
#source $DEVSETTING_DIR/git/mintty-colors-solarized/sol.dark

# show available tmux sessions - https://jamesoff.net/2017/08/26/tmux-configuration.html
if [[ -z $TMUX ]]; then
    sessions=$( tmux ls 2> /dev/null | awk '! /attached/ { sub(":", "", $1); print $1; }' | xargs echo )
    if [[ ! -z $sessions ]]; then
        echo "==> Available tmux sessions: $sessions"
    fi
    unset sessions
fi

source $DEVSETTING_DIR/config/.devsetting.common

# Aliases ---------------------------------------------------------------------
#alias lynx='lynx -vikeys '

function cmakebuild() {
	(mkdir -p build && cd build && conan install --update .. --build missing)
	(cd build && cmake .. && cmake --build . -- VERBOSE=1 -j$(nproc) $@)
}

function tags() {
	rm -f tags
	ctags --exclude="*.java" -R .
}

function strip-ansi-escape() {
	if (( $# < 1 )); then
		echo "Usage: strip-ansi-escape FILES..."
		return
	fi

	sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" $@
}
