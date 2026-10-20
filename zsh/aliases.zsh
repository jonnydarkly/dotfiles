# Aliases from the Mac's ~/.jonnyrc and ~/.launchdarklyrc.
#
# Left out on purpose:
#   claude="$HOME/.local/bin/claude"  on a box claude lives under nvm, and an
#                                     alias named claude takes over the launch
#                                     termag types into the agent pane
#   leg (arch -x86_64)                macOS only
#   awslogin_*                        awslogin isn't on the box

alias c="clear"
alias gp='f(){ git add . && git commit -m "$*" && git push}; f'
alias pk='f(){ kill -9 $(lsof -t -i tcp:$1) }; f'
alias cx="claude --dangerously-skip-permissions"
alias cxc="cx --chrome"
alias gcp='f(){ git add . && git commit -m $1 && git push}; f'
alias gcpa="git add . && git commit --amend --no-edit && git push -f"

# pnpm. `pi` shadows the pi agent CLI when typed by hand (termag launches pi
# through a wrapper script, which aliases don't affect).
alias p='pnpm'
alias pi='p install'
alias px='p run'
alias pa='p add'
alias pad='pa -D'
alias pag='pa -g'
alias pu='p up'
alias pr='p remove'
alias pt='px test'
alias pl='px lint'
alias pb='px build'
alias pd='px dev'
alias pc='p check'
alias pcb='p check:build'
alias ptd='p tauri dev'
alias shadd="pnpm dlx shadcn@latest add"

alias n='npm'
alias ns='npm start'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nr='npm run'

alias y='yarn'
alias yd='yarn dev'
alias ys='yarn start'
alias ya='yarn add'
alias yad='yarn add -D'
alias yr='yarn remove'
alias yt='yarn test'
alias ytt="yarn test:test"
alias yu="yarn utils"
alias yus="yarn utils scratch"
alias yc="yarn spot-check"
alias yl="yarn lint"

# Cache management, with Linux cache paths.
alias cache-status='echo "Bazel: $(if [ -d ~/.cache/bazel-disk-cache ]; then du -sh ~/.cache/bazel-disk-cache | cut -f1; else echo "none"; fi)  Terraform: $(if [ -d ~/.terraform.d/plugin-cache ]; then du -sh ~/.terraform.d/plugin-cache | cut -f1; else echo "none"; fi)  Go: $(if [ -d ~/.cache/go-build ]; then du -sh ~/.cache/go-build | cut -f1; else echo "none"; fi)"'
alias cache-clean-bazel='rm -rf ~/.cache/bazel-disk-cache && echo "Bazel disk cache cleared"'
alias cache-clean-terraform='rm -rf ~/.terraform.d/plugin-cache/* && echo "Terraform plugin cache cleared"'
alias cache-clean-go='go clean -cache && echo "Go build cache cleared"'
alias cache-clean-all='cache-clean-bazel; cache-clean-terraform; cache-clean-go'
