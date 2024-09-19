# Oh My Zsh configurations
# See ~/.oh-my-zsh/templates/zshrc.zsh-template
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
HIST_STAMPS="yyyy-mm-dd"
zstyle ':omz:update' mode auto # update automatically without asking
plugins=(git poetry poetry-env)
source $ZSH/oh-my-zsh.sh
