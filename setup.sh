#!/bin/bash

ZSH_URL=https://raw.githubusercontent.com/romkatv/zsh-bin/master/install

command_exist () {
    command -v $1 > /dev/null
    return $?
}

install_zsh () {
    if command_exist curl; then
        curl -L $ZSH_URL | bash -s -- -d ~/.local -e no
    elif command_exist wget; then
        wget -O- $ZSH_URL | bash -s -- -d ~/.local -e no
    else
        echo no curl and wget >&2
        exit 1
    fi
}

clone_config() {
    git clone https://github.com/philopon/zsh-config.git ~/.config/zsh
    ln -s .config/zsh/zshrc .zshrc
}

install_zsh
clone_config
