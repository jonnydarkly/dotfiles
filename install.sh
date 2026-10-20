#!/usr/bin/env bash
# Applied by termag on every warm-pool box claim (and again by `termag-setup`
# after a GitHub sign-in). Runs as the box user, cwd ~/.dotfiles, no TTY, a
# bare systemd PATH, and a 10-minute timeout. Must be safe to run any number of
# times.
#
# It layers onto the box's baked config instead of replacing it: the baked
# ~/.zshrc carries nvm (without it `claude`/`codex` aren't on PATH), Oh My
# Zsh's non-prompting update mode, and the termag-setup banner.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARK_BEGIN="# >>> jonny dotfiles >>>"
MARK_END="# <<< jonny dotfiles <<<"

log() { printf '[dotfiles] %s\n' "$*"; }
warn() { printf '[dotfiles] WARN: %s\n' "$*" >&2; }

if [[ "$(uname -s)" != Linux ]]; then
  log "box-only installer; nothing to do on $(uname -s)"
  exit 0
fi

# Replace (or add) a marked block in a file, so a re-run updates it in place.
managed_block() {
  local file="$1" body="$2" tmp
  touch "$file"
  tmp="$(mktemp)"
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0 == b { skip = 1; next }
    $0 == e { skip = 0; next }
    !skip
  ' "$file" >"$tmp"
  printf '%s\n%s\n%s\n' "$MARK_BEGIN" "$body" "$MARK_END" >>"$tmp"
  # Write in place so a symlinked target stays a symlink.
  cat "$tmp" >"$file"
  rm -f "$tmp"
}

# Link a file into $HOME unless something is already there.
link_if_absent() {
  local src="$1" dest="$2"
  if [[ -e "$dest" || -L "$dest" ]]; then
    [[ "$(readlink "$dest" 2>/dev/null)" == "$src" ]] || log "keeping existing $dest"
  else
    ln -s "$src" "$dest"
    log "linked $dest"
  fi
}

# --- packages (what the Mac has via Homebrew that the box image lacks) -------
APT_PACKAGES=(fzf silversearcher-ag tree httpie shellcheck parallel psmisc pre-commit protobuf-compiler telnet)
missing=()
for pkg in "${APT_PACKAGES[@]}"; do
  dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed' || missing+=("$pkg")
done
if ((${#missing[@]})); then
  log "apt: installing ${missing[*]}"
  if ! { sudo -n apt-get -o DPkg::Lock::Timeout=180 update -qq &&
    sudo -n env DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=180 install -y -qq "${missing[@]}"; } >/dev/null; then
    warn "apt install failed; continuing without: ${missing[*]}"
  fi
fi

# --- powerlevel10k ------------------------------------------------------------
P10K="$HOME/powerlevel10k"
if [[ ! -d "$P10K/.git" ]]; then
  rm -rf "$P10K"
  git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K"
fi
# Fetch gitstatusd now, so the first shell doesn't download it mid-prompt.
"$P10K/gitstatus/install" -f >/dev/null 2>&1 || warn "gitstatusd prefetch failed; p10k fetches it on first prompt"

# --- zsh ------------------------------------------------------------------------
managed_block "$HOME/.zshrc" "[ -r \"$DOTFILES/zsh/rc.zsh\" ] && source \"$DOTFILES/zsh/rc.zsh\""

# --- tmux -----------------------------------------------------------------------
managed_block "$HOME/.tmux.conf" "source-file -q $DOTFILES/tmux/tmux.conf"
# termag's tmux server is already running at claim; load the additions into it.
tmux source-file -q "$DOTFILES/tmux/tmux.conf" 2>/dev/null || true

# --- git --------------------------------------------------------------------------
# Included from the box's ~/.gitconfig, which keeps its SSH rewrites for the LD
# orgs. Not a symlinked ~/.gitconfig: the claim writes user.name/email there.
if ! git config --global --get-all include.path 2>/dev/null | grep -qxF "$DOTFILES/git/config"; then
  git config --global --add include.path "$DOTFILES/git/config"
fi

# --- gh -----------------------------------------------------------------------------
if command -v gh >/dev/null 2>&1; then
  gh alias set co 'pr checkout' --clobber >/dev/null 2>&1 || warn "gh alias co not set"
fi

# --- tool rc files --------------------------------------------------------------------
link_if_absent "$DOTFILES/home/.bazelrc" "$HOME/.bazelrc"
link_if_absent "$DOTFILES/home/.terraformrc" "$HOME/.terraformrc"
mkdir -p "$HOME/.terraform.d/plugin-cache"

# --- Claude Code preferences ---------------------------------------------------------
# Merged, never replaced: termag's status hooks live in this file.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [[ -f "$CLAUDE_SETTINGS" ]] && command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  if jq '.theme = "dark"' "$CLAUDE_SETTINGS" >"$tmp"; then
    cat "$tmp" >"$CLAUDE_SETTINGS"
  else
    warn "could not merge $CLAUDE_SETTINGS"
  fi
  rm -f "$tmp"
fi

log "applied from $DOTFILES"
