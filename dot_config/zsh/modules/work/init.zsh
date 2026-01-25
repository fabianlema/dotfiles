function __merge_staging() {
  current_branch=`git branch --show`
  git pull --rebase
  git checkout $current_branch
  git merge staging
}

function __merge_f_nx_landing() {
  current_branch=`git branch --show`
  git pull --rebase
  git checkout $current_branch
  git merge f_nx_landing
}

alias merge-staging=__merge_staging
alias merge-nx-staging=__merge_f_nx_landing
alias merge-staging-master='git co master && git merge staging && git p && git co staging'

alias reruntests="git pull && git commit --allow-empty --no-verify -m 'build: rerun tests' && git push"
alias y='yarn'
alias yct='yarn cli:test'
alias yb='yarn bazel'
alias ybb='yarn bazel build'
alias ybt='yarn bazel test'
alias ybtall='yarn bazel test //...'
alias ybr='yarn bazel run'
alias ybc='yarn bazel clean'
alias ybce='yarn bazel clean --expunge'
alias yibt='yarn ibazel test'
alias yibr='yarn ibazel run'
alias yl='yarn lint'
alias yi='yarn install'

alias ws='webstorm .'

function __package_script_select() {
  local package_json="package.json"

  # Check if package.json exists in the current directory
  if [[ ! -f "$package_json" ]]; then
    echo "❌ package.json not found in the current directory."
    return 1
  fi

  # Extract script keys using jq
  local scripts=$(jq -r '.scripts | keys[]' "$package_json")
  if [[ -z "$scripts" ]]; then
    echo "⚠️ No scripts found in package.json."
    return 1
  fi

  # Open fzf for interactive selection
  local selected=$(echo "$scripts" | fzf --prompt="Select a script: ")

  # Handle cancellation or empty selection
  if [[ -z "$selected" ]]; then
    echo "🚫 Cancelled."
    return 0
  fi

  # Execute the selected script using yarn
  echo "🚀 Running: yarn $selected"
  yarn "$selected"
}
alias yscr=__package_script_select
