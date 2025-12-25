# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# If bash_aliases exists, source it
if [ -f ~/.config/.bash_aliases ]; then
    . ~/.config/.bash_aliases
fi

# Created by `pipx` on 2025-11-09 22:29:38
export PATH="$PATH:/home/monty/.local/bin"
