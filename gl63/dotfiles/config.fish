#!/usr/bin/fish

## Abbreviations

# Bash like
abbr !! "$history[1]"

# Openpepe
abbr zyppi "sudo zypper in"
abbr zyppr "sudo zypper rm"
abbr zyppup "sudo zypper dup"
abbr zyppu "sudo zypper refresh"

# Arch linux
abbr pac "sudo pacman"
abbr paci "sudo pacman -S"
abbr pacr "sudo pacman -Rnc"
abbr pacc "sudo pacman -Rnc (pacman -Qtdq)"
abbr pacup "sudo pacman -Syu"

# Fedora
abbr dnfi "sudo dnf install"
abbr dnfr "sudo dnf remove"
abbr dnfup "sudo dnf update"
abbr dnfs "sudo dnf search"
abbr dnfar "sudo dnf autoremove"

# Systemctl
abbr SS "sudo systemctl"
abbr SSenable "sudo systemctl enable"
abbr SSstart "sudo systemctl start"
abbr SSstatus "sudo systemctl status"
abbr SSstop "sudo systemctl stop"
abbr SSdisable "sudo systemctl disable"
abbr SSrestart "sudo systemctl restart"
