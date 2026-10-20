# Sourced at the end of the box's ~/.zshrc (install.sh adds the line), after
# Oh My Zsh, nvm, goenv and pyenv are already set up.
#
# Nothing here may read stdin or exec another program: termag types the agent
# launch into a pane about half a second after creating it.

_dotfiles="${${(%):-%x}:A:h:h}"

source "$_dotfiles/zsh/aliases.zsh"

# From ~/.launchdarklyrc on the Mac.
ulimit -n 8192 2>/dev/null
export GOPRIVATE="github.com/launchdarkly"
export AWS_SDK_LOAD_CONFIG=true

# Powerlevel10k, the same lean config as the Mac. Loaded after Oh My Zsh, so it
# takes over the prompt from the baked robbyrussell theme. Cursor agent shells
# keep a plain prompt, as on the Mac.
if [[ -z ${CURSOR_AGENT:-} && -r "$HOME/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/powerlevel10k/powerlevel10k.zsh-theme"
  source "$_dotfiles/zsh/p10k.zsh"
  # termag's browser terminal uses JetBrains Mono / Fira Code, which have no
  # Nerd Font glyphs. Set DOTFILES_NERD_FONT=1 (e.g. in ~/.zshrc.local) when
  # you only reach the box from a terminal with a Nerd Font.
  [[ ${DOTFILES_NERD_FONT:-0} == 1 ]] || typeset -g POWERLEVEL9K_MODE=compatible
elif [[ -n ${CURSOR_AGENT:-} ]]; then
  PROMPT='%n@%m:%~%# '
  RPROMPT=''
fi

# Per-box, uncommitted overrides.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

unset _dotfiles
