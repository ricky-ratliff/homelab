# rknix Bash Alias Definitions

This document contains a copy of my current alias definitions on Ubuntu 22.04 and notes.

## Current Alias Definitions

```sh
#  BASH Alias definitions as referenced in ~/.bashrc  

## Core/Builtin Program Aliases

    ### Directory Listing
    
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
    alias lsl='ls -lah'
    alias lsr='ls -lahR'

    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    ### grep
    
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    ### apt
    
    alias checkupdates='sudo apt update && sudo apt list --upgradable -v'
    alias getupdates='sudo apt update && sudo apt upgrade -y'
    alias safeupdate='sudo apt update && sudo apt upgrade | tee -a ~/apt-upgrade.log'
    alias fullupdate='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean'

## Monitoring & Alerts

    # Add an "alert" alias for long running commands.  
    # Use like so:
    #   sleep 10; alert
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

## User Installed Program Aliases

    ### system utilities
    alias vtop='vtop -t gruvbox'
    alias ffls='fastfetch -l small'
    alias bandwhich='~/Documents/IT/Homelab/networking/bandwhich-v0.23.1-x86_64-unknown-linux-gnu/bandwhich'

    ### other
    alias botany='python3 /home/ricky/Documents/Gaming/botany/botany.py'
```

---

## Alias Definition Notes

### :exclamation: Remember to Make Aliases Persistent

Add them to `~/.bash_aliases` file after testing

### Apt

Common system update/upgrade tasks with `apt`

### 🔎 Update & show list of upgradable packages with verbose output (no install)

```bash
alias checkupdates='sudo apt update && sudo apt list --upgradable -v'
# 'apt list --upgradable -v' - Shows a list of packages that have available updates with verbose output.
```

### :package: Basic update & upgrade alias

```bash
alias getupdates='sudo apt update && sudo apt upgrade -y'
# 'sudo apt update'     - Refreshes the package list from repositories
# '&&'                  - Ensures upgrade only runs if update is successful
# 'sudo apt upgrade -y' - Upgrades all upgradable packages without prompting
```

### :memo: Update with logging

```bash
alias safeupdate='sudo apt update && sudo apt upgrade | tee -a ~/apt-upgrade.log'
# 'tee -a'           - Logs (appends) the output to apt-upgrade.log in your home directory for later review
```

### 🧼 Full update + cleanup chain

```bash
alias fullupdate='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean'
# 'sudo apt update'        - Updates the list of available packages
# 'sudo apt upgrade -y'    - Installs available updates
# 'sudo apt autoremove -y' - Removes unused packages automatically
# 'sudo apt autoclean'     - Cleans up retrieved package files (older .deb files)
```

### 🪛 Dist-upgrade alias for smarter package resolution

```bash
alias distupgrade='sudo apt update && sudo apt full-upgrade -y'
# 'apt full-upgrade' - Installs upgrades, removes obsolete packages, and handles dependency changes
```
