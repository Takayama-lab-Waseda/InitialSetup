alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias v='nvim'
alias p='python3'
alias dl="cd (Downloadsのファイルパスを追加する)"
alias color256='for code in {000..255}; do print -nP -- "%F{$code}$code %f"; [ $((${code} % 16)) -eq 15 ] && echo; done'

venv_prompt() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "%F{006}@$(basename "$VIRTUAL_ENV")%F{255} "
  else
    echo ""
  fi
}

git_prompt() {
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$branch" ]] && return

  local staged=$(git status --porcelain 2>/dev/null | awk '{if (substr($0,1,1) != " " && substr($0,1,1) != "?") print}' | wc -l | tr -d " ")
  local unstaged=$(git status --porcelain 2>/dev/null | awk '{if (substr($0,2,1) != " ") print}' | wc -l | tr -d " ")
  local uncommitted=$((staged + unstaged))

  local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
  local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)

  local prompt_status="%F{244}[%F{113}$branch"

  if [[ "$ahead" -gt 0 ]]; then
    prompt_status+=" %F{166}↑$ahead"
  fi
  if [[ "$behind" -gt 0 ]]; then
    prompt_status+=" %F{166}↓$behind"
  fi
  if [[ "$uncommitted" -gt 0 ]]; then
    prompt_status+="%F{166} ✗$uncommitted"
  fi
  if [[ "$ahead" -eq 0 && "$behind" -eq 0 && "$uncommitted" -eq 0 ]]; then
    prompt_status+=" *"
  fi

  prompt_status+="%F{244}]"
  echo " $prompt_status"
}

set_prompt() {
  local pwd="${PWD}"
  local parent_dir="$(basename $(dirname $pwd))"
  local current_dir="$(basename $pwd)"
  local max_length=12

  if [[ ${#parent_dir} -gt $max_length ]]; then
    parent_dir="${parent_dir:0:$max_length}~"
  fi
  if [[ ${#current_dir} -gt $max_length ]]; then
    current_dir="${current_dir:0:$max_length}~"
  fi
  PS1="$(venv_prompt)%F{219}%n%F{244}:%F{141}${parent_dir}/${current_dir}%F{255}$(git_prompt)%F{255} %# "
}

activate_virtualenv(){
  if [[ -n "$VIRTUAL_ENV" ]]; then
    set_prompt
  fi
}

autoload -Uz colors && colors
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt
typeset -U path PATH

export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export PYTHONSTARTUP=~/.pythonrc

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

HISTFILE=~/.zsh_history
HISTSIZE=2000
SAVEHIST=2000

setopt extended_glob
setopt correct
setopt append_history
setopt hist_ignore_dups
setopt share_history
setopt inc_append_history

