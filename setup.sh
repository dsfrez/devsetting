#!/bin/sh

## Script preferences #########################################################
DEVSETTING_GIT=`dirname $(readlink -f "$0")`
DEVSETTING_DIR=$HOME/.devsetting

systemMessage=""

## Check current environments #################################################
currentShell=${SHELL##*/}
supportNVIM=0

case "$(uname -s)" in
    Linux*)     machine=Linux; supportNVIM=1;;
    Darwin*)    machine=Mac; supportNVIM=1;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
# TODO: check distribution of linux

## generate / backup configurations ###########################################
[ ! -d "$DEVSETTING_DIR/bin" ] && mkdir -p $DEVSETTING_DIR/bin
[ ! -d "$DEVSETTING_DIR/git" ] && mkdir -p $DEVSETTING_DIR/git
[ ! -L "$DEVSETTING_DIR/config" ] && ln -s $DEVSETTING_GIT/config $DEVSETTING_DIR/config
[ ! -L "$DEVSETTING_DIR/script" ] && ln -s $DEVSETTING_GIT/script $DEVSETTING_DIR/script
[ ! -d "$HOME/.vim" ] && mkdir $HOME/.vim
if [ $supportNVIM = 1 ]; then
    if [ ! -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        mkdir -p $HOME/.config
        ln -s $HOME/.vim $HOME/.config/nvim
    fi
fi

# backup old config
backupDir="$HOME/config_bakup_$(date +%y%m%d%H%M%S)"
mkdir -p $backupDir

update_configures() {
    if [ -f "$HOME/$1" ] && [ ! -L "$HOME/$1" ]; then
        msg="$1 will be moved into $backupDir\n"
        systemMessage=$SYSTEM_MESSAGE$msg
        mv $HOME/$1 $backupDir
    elif  [ -L "$HOME/$1" ]; then
        msg="update symlink of $1\n"
        systemMessage=$SYSTEM_MESSAGE$msg
        unlink $HOME/$1
    fi
    ln -s $DEVSETTING_DIR/config/$1 $HOME/$1
}
update_configures .vimrc
update_configures .tigrc
update_configures .tmux.conf

if [ $supportNVIM = 1 ]; then
    if [ -f "$HOME/.config/nvim/init.vim" ] && [ ! -L "$HOME/.config/nvim/init.vim" ]; then
        msg="init.vim will be moved into $backupDir\n"
        systemMessage=$SYSTEM_MESSAGE$msg
        mv $HOME/.config/nvim/init.vim $backupDIR
    elif  [ -L "$HOME/.config/nvim/init.vim" ]; then
        msg="update symlink of init.vim\n"
        systemMessage=$SYSTEM_MESSAGE$msg
        unlink $HOME/.config/nvim/init.vim
    fi
    ln -s $HOME/.vimrc $HOME/.config/nvim/init.vim
fi


# add bashrc/zshrc setting into init script
bashInit="devsetting.bash"
bashRc="$HOME/.bashrc"
[ ! -f $bashRc ] && touch $bashRc
if [[ $(grep -nw $bashInit $bashRc) == "" ]]; then
    echo "[ -f $DEVSETTING_DIR/config/$bashInit ] && source $DEVSETTING_DIR/config/$bashInit" >> $bashRc
fi

zshInit="devsetting.zsh"
zshRc="$HOME/.zshrc"
if [ -f $zshRc ] && [[ $(grep -nw $zshInit $zshRc) != "" ]]; then
    : # do nothing
else
    if [ -f $zshRc ]; then
        msg=".zshrc will be moved into $backupDir\n"
        systemMessage=$SYSTEM_MESSAGE$msg
        mv $zshRc $backupDir
        touch $zshRc
        echo "# Your previous .zshrc was stored at $backupDir" >> $zshRc
    else
        touch $zshRc
    fi
    echo "# If you want to use your own setting, please comment out below line" >> $zshRc
    echo "# please comment out below line and write your setting" >> $zshRc
    echo "[ -f $DEVSETTING_DIR/config/$zshInit ] && source $DEVSETTING_DIR/config/$zshInit" >> $zshRc
fi

## Download external libraries ################################################
# NeoVim - https://github.com/neovim/neovim/wiki/Installing-Neovim
# TODO: check nvim version
if [ $supportNVIM = 1 ] && [ -z "$(command -v nvim)" ]; then
    if [ "$machine" = "Linux" ]; then
        cd $DEVSETTING_DIR/bin
        wget https://github.com/neovim/neovim/releases/download/v0.3.4/nvim.appimage --no-check-certificate
        chmod +x nvim.appimage
        mv nvim.appimage nvim
    fi
fi

[ ! -d "$DEVSETTING_DIR/git/tmux" ] &&
    git clone https://github.com/tmux/tmux.git $DEVSETTING_DIR/git/tmux
[ ! -d "$DEVSETTING_DIR/git/uctag" ] &&
    git clone https://github.com/universal-ctags/ctags.git $DEVSETTING_DIR/git/uctag
[ ! -d "$DEVSETTING_DIR/git/ag" ] &&
    git clone https://github.com/ggreer/the_silver_searcher.git $DEVSETTING_DIR/git/ag

## Post processing ############################################################
[ -z "$(ls -A $backupDir)" ] && rmdir $backupDir

echo -e $systemMessage
echo "Please re-execute shell or type \"source .${currentShell}rc\""
