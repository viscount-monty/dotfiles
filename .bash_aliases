##################################################################
# General                                                        #
##################################################################
# ls aliases
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'

# Open README.md in Neovim
alias nr='nvim README.md'

# Functions
# Test function to demonstrate function capabilities
test_function() {
  dir_name=${PWD##*/}
  dir_name=${dir_name:-/}
  printf '%s\n' "Current directory name: ${dir_name}"
}

# Set monitor brightness
mb() {
  ~/.set_monitor_brightness.sh "${1:-0}"
}

##################################################################
# Git                                                            #
##################################################################
# Status short format
alias gs='git status -s'
# Make current directory published private GitHub repo
gp() {
  echo 'Adding .venv/ to .gitignore'
  echo '.venv/' >>.gitignore
  echo 'Initialising git repository...'
  git init
  echo 'Staging files...'
  git add .
  echo 'Performing initial commit...'
  git commit -m 'initial commit'
  echo 'Pushing to private repository'
  gh repo create --source=. --private --push
}

# Git log, one line, with pretty formatting
gl() {
  git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short -"${1:-10}"
}

##################################################################
# Python                                                         #
##################################################################
# Python
alias py='python3'
# Micropython tool mpremote
alias mp='mpremote'
# Activate venv
alias va='. .venv/bin/activate'
# Deactivate venv
alias vd='deactivate'

# Create venv
vc() {
  echo 'Creating .venv'
  python3 -m venv .venv
}

##################################################################
# Backup dotfiles in $HOME with bare repo                        #
##################################################################

# Location of dotfile bare repository
DOTFILES="$HOME/.dotfiles"

# Convenience function, to be used in place of 'git' for dotfile repo
# "$@" represents "all arguments passed to this script/function"
dc() {
  git --git-dir="$DOTFILES" --work-tree="$HOME" "$@"
}

# Status short format
alias dcs='dc status -s'

# Git log, one line, with pretty formatting
dcl() {
  dc log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short -"${1:-10}"
}

# Set up a new repo ready to be populated and pushed to an empty remote repo
dcn() {
  mkdir $DOTFILES
  git init --bare $DOTFILES
  dc config --local status.showUntrackedFiles no
  echo "Add and commit additional files using:"
  echo "    dc add"
  echo "    dc commit"
  echo "Then run:"
  echo "    dc remote add origin <remote-url>"
  echo "    dc push -u origin main"
}

# Accepts an already-populated remote repo URL, pulls the files into $HOME
dcr() {
  git clone -b base --bare $1 $DOTFILES
  dc config --local status.showUntrackedFiles no
  dc checkout || echo -e 'Deal with conflicting files, then run (possibly with -f flag if you are OK with overwriting)\ndc checkout'
}
