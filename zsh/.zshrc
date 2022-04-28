#!/bin/zsh

# .zshrc
autoload -U +X bashcompinit && bashcompinit
autoload -U promptinit; promptinit
autoload -Uz compinit
compinit
# prompt pure

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.config/dotfiles/.p10k.zsh ]] || source ~/.config/dotfiles/.p10k.zsh


[[ -e ~/.phpbrew/bashrc ]] && source ~/.phpbrew/bashrc

source /opt/homebrew/opt/powerlevel10k/powerlevel10k.zsh-theme


export FZF_DEFAULT_COMMAND='ag --follow --nocolor --ignore node_modules -g ""'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

for file in $(find ~/.config/dotfiles); do
  [ -f "$file" ] && source "$file"
done
  
# Updates editor information when the keymap changes.
function zle-keymap-select() {
  # update keymap variable for the prompt
  VI_KEYMAP=$KEYMAP

  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select

function vi-accept-line() {
  VI_KEYMAP=main
  zle accept-line
}

zle -N vi-accept-line


bindkey -v

# use custom accept-line widget to update $VI_KEYMAP
bindkey -M vicmd '^J' vi-accept-line
bindkey -M vicmd '^M' vi-accept-line

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# run find-project when pressing ctrl+F
bindkey -s '^F' 'find-project\n'

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r and ctrl-s to search the history
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# if mode indicator wasn't setup by theme, define default
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
fi

function vi_mode_prompt_info() {
  echo "${${VI_KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# define right prompt, if it wasn't defined by a theme
if [[ "$RPS1" == "" && "$RPROMPT" == "" ]]; then
  RPS1='$(vi_mode_prompt_info)'
fi

# Run the default dev environment
# Re-enable dev with stow later
# dev

# Kubectl autocomplete
source <(kubectl completion zsh)

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

complete -F __start_kubectl k

if [ "$TERM" != "screen-256color" ]; then
  export TERM=screen-256color
fi


[ ! -z "${TMUX+x}" ] && export TERM="screen-256color"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
