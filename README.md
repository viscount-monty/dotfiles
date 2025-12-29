# .dotfiles

## Description

A backup of the configuration files which reside in the home directory of Linux operating systems.

This approach supersedes the "home directory is a repo with everything ignored except what I want to back up" as that resulted in some undesired behaviour, specifically with Google Antigravity agents not having access to files covered by the .gitignore file (everything in the home directory other thand a few config files)

- Based on this [this gist](https://gist.github.com/viscount-monty/f4c42fd3790f239ac0ca0c72a742d897)

## Objectives

- [ ] Configure Neovim to work with bare repo method
    - [ ] Gitsigns
    - [ ] Lazgit
- [ ] Ensure all aliases functions work correctly
    - [x] `dc` Convenience function used in place of `git`
    - [ ] `dcs` Git status, short format
    - [ ] `dcl` Git log, one line per entry, pretty formatting
    - [ ] `dcn` Set up a new repo ready to be populated and pushed to an empty remote repo
    - [ ] `dcr` Accepts an established remote repo URL and pulls the files into $HOME
- [ ] Move key instructions of gist into `README.md`
- [ ] Ensure `.bashrc` is compatible with
    - [ ] Linux Mint
    - [ ] Ubuntu 24.04 LTS (WSL)
    - [ ] Raspberry Pi OS
