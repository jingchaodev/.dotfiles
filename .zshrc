# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"


# Disable Kaku Smart Tab so fzf tab completion works
export KAKU_SMART_TAB_DISABLE=1

# Cline
if [[ -n "${VSCODE_GIT_ASKPASS_NODE}" ]]; then
  export PATH=$(dirname ${VSCODE_GIT_ASKPASS_NODE})/bin/remote-cli:${PATH}
fi
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)
DISABLE_COMPFIX=true
skip_global_compinit=1
source $ZSH/oh-my-zsh.sh

# History (override oh-my-zsh defaults)
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# PATH
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
export PATH=$PATH:/Users/cjingcha/.toolbox/bin
export PATH="/Users/cjingcha/.local/bin:$PATH"
export PATH="$HOME/.nodenv/bin:$PATH"
# export PATH="/opt/homebrew/opt/node@14/bin:$PATH"  # removed: using mise for node
export PATH="$HOME/bin:$PATH"
export PATH="/Users/cjingcha/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/.aim/mcp-servers:$PATH"

# nvm removed — using mise for node version management
# export NVM_DIR=~/.nvm

# Interactive cd (was sourced twice before)
source ~/.zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Key bindings
bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=yellow'

# Soften syntax highlighting colors (Ghostty renders bold brighter than iTerm2)
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=green'

# Aliases
alias bb="brazil-build"
alias mountCloudDesktop="sshfs cjingcha-clouddesk.aka.corp.amazon.com:/home/cjingcha/workplace ~/cloud-workplace"
alias kinit="/usr/bin/kinit -f -l 36000 -r 604800"
alias ssh="ssh -o ServerAliveInterval=10"
alias klist="/usr/bin/klist"
alias ls="eza"
alias ll="eza -la --git"
alias tree="eza --tree --level=3"

# FZF defaults
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=light,fg:#4d4d4c,bg:-1,hl:#d7005f,fg+:#4d4d4c,bg+:#d6d6d6,hl+:#d7005f,info:#4271ae,prompt:#8959a8,pointer:#d7005f,marker:#4271ae,spinner:#4271ae"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=up:3:wrap"

# brazil-build override
brazil-build() {
  if [ $# -eq 0 ]; then
    command brazil-build clean && command brazil-build
  else
    command brazil-build "$@"
  fi
}

# Lazy-load conda (saves ~0.5s)
conda() {
  unset -f conda
  __conda_setup="$('/Users/cjingcha/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "/Users/cjingcha/anaconda3/etc/profile.d/conda.sh" ]; then
      . "/Users/cjingcha/anaconda3/etc/profile.d/conda.sh"
    else
      export PATH="/Users/cjingcha/anaconda3/bin:$PATH"
    fi
  fi
  unset __conda_setup
  conda "$@"
}

# Jina CLI
if [[ -o interactive ]]; then
  compctl -K _jina jina
  _jina() {
    local words completions
    read -cA words
    if [ "${#words}" -eq 2 ]; then
      completions="$(jina commands)"
    else
      completions="$(jina completions ${words[2,-2]})"
    fi
    reply=(${(ps:\n:)completions})
  }
fi
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# Cached compinit (only regenerates once per day)
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# mise (shims mode — instant, avoids 1.2s eval)
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Mechanic
[ -f "$HOME/.local/share/mechanic/complete.zsh" ] && source "$HOME/.local/share/mechanic/complete.zsh"

# Kiro shell integration
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# iTerm2
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Cling helper
function cling() {
  local folders=()
  for arg in "$@"; do
    if [ -d "$arg" ]; then
      folders+=("$arg")
    elif [ -f "$arg" ]; then
      folders+=("$(dirname "$arg")")
    fi
  done
  open -a Cling "${folders[@]}"
}

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

# MeshClaw
export PATH="/Users/cjingcha/workspace/MeshClaw/src/MeshClaw/bin:$PATH"

# Midway refresh (FIDO2 + SSH cert)
alias mw='mwinit -s -f'
# Fast meshclaw token — bypasses slow brazil-runtime-exec
mctoken() {
  local secret=$(cat ~/.meshclaw/.local_secret 2>/dev/null) || { echo "❌ Gateway not running"; return 1; }
  local resp=$(curl -s --max-time 5 -H "X-Local-Secret: $secret" "http://localhost:${1:-7777}/api/token/local?ttl=20h" 2>&1)
  local token=$(echo "$resp" | python3 -c "import sys,json; print(json.load(sys.stdin).get('token',''))" 2>/dev/null)
  [ -z "$token" ] && { echo "❌ Could not get token: $resp"; return 1; }
  echo "http://localhost:${1:-7777}?token=$token"
}

[[ ":$PATH:" != *":$HOME/.config/kaku/zsh/bin:"* ]] && export PATH="$HOME/.config/kaku/zsh/bin:$PATH" # Kaku PATH Integration
[[ -f "$HOME/.config/kaku/zsh/kaku.zsh" ]] && source "$HOME/.config/kaku/zsh/kaku.zsh" # Kaku Shell Integration

# Kiro CLI shortcuts
alias kr="kiro-cli chat -r -a"
alias krp="kiro-cli chat --resume-picker -a"
