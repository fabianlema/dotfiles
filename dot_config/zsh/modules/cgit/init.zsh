

function __create_tag() {
  git tag -a $1 -m "$1"
}

function __delete_branches() {
selected_branches=$(git branch --list | sed 's/\*//g' | fzf --multi)

if [ -n "$selected_branches" ]; then
    while read -r branch; do
        git branch -D "$branch"
    done <<< "$selected_branches"
fi
}

alias g='git'
alias gst='git status'
alias gss='git status -s'
alias gcb='git checkout -b'
alias gbd='git branch -d'
alias gbcp='git branch --show-current | pbcopy' 
alias gco='git checkout'
alias gbd=__delete_branches
alias ga='git add -A'
alias gca='git commit --amend'
alias gcam='git commit -a -m'
alias gm='git merge'
alias gms='git merge --squash'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gdw='git diff --word-diff'
alias grm='git rm'
alias grmc='git rm --cached'
alias gr='git reset --'
alias grh='git reset --hard'
alias gl='git log --graph --pretty='\''%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'\'
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias gsta='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash save'
alias grev='git revert'
alias gct=__create_tag
alias grt='git tag -d'
alias grrt='git push --delete origin';
alias gpt='git push origin'
alias gpl='git pull'
alias gcl='git restore --staged . && git restore . && git clean -fd'
# --- Git Worktrees Utils ---

# Internal function to clone repository with bare structure
function __gclone_wt() {
  url=$1
  # Use repo name if no folder argument is provided
  dir=${2:-$(basename "$url" .git)}

  echo "🏗️  Creating Worktree structure for: $dir..."

  mkdir "$dir"
  cd "$dir"

  # 1. Clone as bare repository
  git clone --bare "$url" .git

  # 2. Configure fetch to ensure all remote branches are visible
  git config --local remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

  # 3. Attempt to checkout 'main' or 'master'
  if git show-ref --verify --quiet refs/heads/main; then
      git worktree add main
  elif git show-ref --verify --quiet refs/heads/master; then
      git worktree add master
  else
      echo "⚠️ 'main' or 'master' not found. You need to create the worktree manually."
  fi

  echo "✅ Repo ready. Enter via: cd $dir/main"
}

# Internal function to add a new worktree and copy node_modules if available
function __gw_co() {
    local dir_name=$1
    local branch_name=${2:-$1}
    
    # Create the worktree
    echo "🌿 Creating worktree: $dir_name..."
    git worktree add "$dir_name" "$branch_name"
    
    # Define source for node_modules (looking into main or master)
    # Assumes execution from project root
    #local src_modules=""
    #if [ -d "main/node_modules" ]; then
    #   src_modules="main/node_modules"
    #elif [ -d "master/node_modules" ]; then
    #    src_modules="master/node_modules"
    #fi

    # Copy node_modules using rsync if found to speed up setup
    #if [ -n "$src_modules" ]; then
    #    echo "📦 Found node_modules in $src_modules. Copying..."
    #    rsync -a --info=progress2 "$src_modules/" "$dir_name/node_modules/"
    #fi
    cd $dir_name
    echo "✅ Done $dir_name"
}

# Internal function to remove worktree cleanly
function __gw_rm() {
    echo "🗑️ Removing worktree: $1..."
    git worktree remove "$1"
}

# --- Aliases ---

# gclwt: Clones a new repo with bare/worktree structure
# Usage: gclwt <url> [folder-name]
alias gclwt=__gclone_wt

# gwco: Adds a new branch/worktree (and copies node_modules)
# Usage: gwco <folder-name> [branch-source]
alias gwco=__gw_co

# gwrm: Removes a worktree
# Usage: gwrm <folder-name>
alias gwrm=__gw_rm

# gwls: Lists active worktrees
alias gwls='git worktree list'
