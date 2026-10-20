# dotfiles

My shell setup for termag boxes. termag clones this repo to `~/.dotfiles` when I claim a box from
the warm pool and runs `install.sh`.

## What it sets up

| | |
|---|---|
| **zsh** | Powerlevel10k with my lean config, my aliases from `~/.jonnyrc`, `GOPRIVATE`, `ulimit -n 8192` |
| **packages** | fzf, ag, tree, httpie, shellcheck, parallel, pstree, pre-commit, protoc, telnet (the box image already has git, gh, tmux, ripgrep, zoxide, jq, nvim, terraform, awscli, docker) |
| **tmux** | mouse on (on top of the box's config) |
| **git** | name and email, included from the box's `~/.gitconfig` |
| **gh** | `gh co` = `gh pr checkout` |
| **bazel / terraform** | shared disk cache and plugin cache (`~/.bazelrc`, `~/.terraformrc`) |
| **Claude Code** | dark theme, merged into `~/.claude/settings.json` |

## How it fits the box

`install.sh` adds to the box's config and never replaces it. The box's own `~/.zshrc` (nvm, Oh My
Zsh, the `termag-setup` banner), `~/.tmux.conf`, `~/.gitconfig` and `~/.claude/settings.json` stay.
It appends one marked block to `~/.zshrc` and `~/.tmux.conf`, which source `zsh/rc.zsh` and
`tmux/tmux.conf`. Re-running it is safe and updates the blocks in place.

On macOS it does nothing.

Things deliberately left out:
- `alias claude=…`, because termag types `claude` into the agent pane
- the Mac's gh credential helper and its `https` `insteadOf` rule, which would bypass the box's
  SSH rewrites and termag's GitHub broker
- Nerd Font icons, because termag's browser terminal has no Nerd Font. Put `export DOTFILES_NERD_FONT=1` in
  `~/.zshrc.local` on a box you only reach over SSH from a Nerd Font terminal.

## Changing it

Edit, push, then on a box: `git -C ~/.dotfiles pull && bash ~/.dotfiles/install.sh`. Boxes claimed
later pick it up automatically. Per-box tweaks go in `~/.zshrc.local`, which isn't in the repo.

The apply log is `~/.termag/on-claim.log`.
