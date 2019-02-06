export DEVSETTING_DIR=$HOME/.devsetting
source $DEVSETTING_DIR/config/.devsetting.common

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
