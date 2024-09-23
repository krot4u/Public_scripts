# add-apt-repository ppa:ultradvorka/ppa
# apt update
# apt install hstr
# On Debain: hstr --show-configuration >> ~/.bashrc

# apt install bat fzf zsh fd-find
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# theme agnoster

plugins=(git kubectl docker eza kube-ps1)

# Source fzf key bindings and fuzzy completion
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

alias ll='fzf --preview "bat --color=always --style=numbers {}"'
# ln -s /usr/bin/fdfind /usr/local/bin/fd
# ln -s /usr/bin/batcat /usr/local/bin/bat

# -- Use fd instead of fzf --
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# --- setup fzf theme ---
fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

source <(kubectl completion zsh)
alias kk=kubectl
compdef __start_kubectl kk

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---- Eza (better ls) -----
alias ls="eza --color=always --long --git --icons=always --group-directories-first"

alias kgc=kubectx
alias kgn=kubens

export KUBECONFIG=/mnt/c/Users/zabirov/.kube/config

#source "/opt/kube-prompt.sh"
#PROMPT=$PROMPT'$(__kube_ps1)'
source "/home/linuxbrew/.linuxbrew/opt/kube-ps1/share/kube-ps1.sh"
RPS1='$(kube_ps1)'

# ---- Zoxide (better cd) ----
eval "$(zoxide init zsh)"
alias cd="z"