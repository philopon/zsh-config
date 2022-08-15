typeset -U path

ZSH_CONFIG_BASE=$(dirname $(readlink -f ~/.zshrc))

# https://github.com/ogham/exa/issues/544#issuecomment-1094888689
export LS_COLORS="*.arw=38;5;133:*.bmp=38;5;133:*.cbr=38;5;133:*.cbz=38;5;133:*.cr2=38;5;133:*.dvi=38;5;133:*.eps=38;5;133:*.gif=38;5;133:*.heif=38;5;133:*.ico=38;5;133:*.jpeg=38;5;133:*.jpg=38;5;133:*.nef=38;5;133:*.orf=38;5;133:*.pbm=38;5;133:*.pgm=38;5;133:*.png=38;5;133:*.pnm=38;5;133:*.ppm=38;5;133:*.ps=38;5;133:*.raw=38;5;133:*.stl=38;5;133:*.svg=38;5;133:*.tif=38;5;133:*.tiff=38;5;133:*.webp=38;5;133:*.xpm=38;5;133:*.avi=38;5;135:*.flv=38;5;135:*.heic=38;5;135:*.m2ts=38;5;135:*.m2v=38;5;135:*.mkv=38;5;135:*.mov=38;5;135:*.mp4=38;5;135:*.mpeg=38;5;135:*.mpg=38;5;135:*.ogm=38;5;135:*.ogv=38;5;135:*.ts=38;5;135:*.vob=38;5;135:*.webm=38;5;135:*.wmvm=38;5;135:*.djvu=38;5;105:*.doc=38;5;105:*.docx=38;5;105:*.dvi=38;5;105:*.eml=38;5;105:*.eps=38;5;105:*.fotd=38;5;105:*.key=38;5;105:*.odp=38;5;105:*.odt=38;5;105:*.pdf=38;5;105:*.ppt=38;5;105:*.pptx=38;5;105:*.rtf=38;5;105:*.xls=38;5;105:*.xlsx=38;5;105:*.aac=38;5;92:*.alac=38;5;92:*.ape=38;5;92:*.flac=38;5;92:*.m4a=38;5;92:*.mka=38;5;92:*.mp3=38;5;92:*.ogg=38;5;92:*.opus=38;5;92:*.wav=38;5;92:*.wma=38;5;92:*.7z=31:*.a=31:*.ar=31:*.bz2=31:*.deb=31:*.dmg=31:*.gz=31:*.iso=31:*.lzma=31:*.par=31:*.rar=31:*.rpm=31:*.tar=31:*.tc=31:*.tgz=31:*.txz=31:*.xz=31:*.z=31:*.Z=31:*.zip=31:*.zst=31:*.asc=38;5;109:*.enc=38;5;109:*.gpg=38;5;109:*.p12=38;5;109:*.pfx=38;5;109:*.pgp=38;5;109:*.sig=38;5;109:*.signature=38;5;109:*.bak=38;5;244:*.bk=38;5;244:*.swn=38;5;244:*.swo=38;5;244:*.swp=38;5;244:*.tmp=38;5;244:*.~=38;5;244:pi=33:cd=33:bd=33:di=34;1:so=36:or=36:ln=36:ex=32;1:"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

__command_exist () {
    command -v $1 &> /dev/null
    return $?
}

__push_paths () {
    for p in "$@"; do
        if [[ -d "$p" ]]; then
            path=($p $path[@])
        fi
    done
}

__init_homebrew () {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        alias abrew="arch -arch arm64 /opt/homebrew/bin/brew"
        alias brew=abrew
    fi

    if [[ -x /usr/local/bin/brew ]]; then
        alias ibrew="arch -arch x86_64 /usr/local/bin/brew"
        [[ "$(uname -p)" != "arm" ]] && alias brew=ibrew
    fi

    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_AUTO_UPDATE=1
}

__peco_select_history () {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER" --layout=bottom-up)
  CURSOR=$#BUFFER
}

__peco_ghq_repository () {
    BUFFER="cd $(ghq list --full-path | peco --query "$LBUFFER" --layout=bottom-up)"
    zle accept-line
}

__init_keybinds () {
    zle -N __peco_select_history
    bindkey '^r' __peco_select_history

    zle -N __peco_ghq_repository
    bindkey '^g' __peco_ghq_repository

    autoload -Uz history-search-end
    zle -N history-beginning-search-backward-end history-search-end
    zle -N history-beginning-search-forward-end history-search-end
    bindkey '^p' history-beginning-search-backward-end
    bindkey '^n' history-beginning-search-forward-end
}

__init_history () {
    export HISTSIZE=1000
    export SAVEHIST=100000
    setopt hist_ignore_dups
    setopt EXTENDED_HISTORY
    setopt share_history
    setopt hist_ignore_all_dups
    setopt hist_reduce_blanks  
    setopt hist_save_no_dups
    setopt hist_no_store
}

__init_zinit () {
    local ZINIT_INIT=$ZSH_CONFIG_BASE/zinit/zinit.git/zinit.zsh
    if [[ ! -f $ZINIT_INIT ]]; then
        ZINIT_HOME=~/.config/zsh/zinit NO_EDIT=1 bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    fi

    source $ZINIT_INIT

    zinit light zsh-users/zsh-autosuggestions
    zinit light zdharma-continuum/fast-syntax-highlighting

    if __command_exist python3; then
        path=($path[@] $ZSH_CONFIG_BASE/compat/python3)
    fi

    zinit ice from"gh-r" as"program" pick"*/peco"
    zinit light "peco/peco"

    zinit ice from"gh-r" as"program"
    zinit light "starship/starship"

    zinit ice from"gh-r" as"program" pick"*/exa"
    zinit light "ogham/exa"

    zinit ice from"gh-r" as"program" pick"*/ghq"
    zinit light "x-motemen/ghq"

    zinit ice from"gh-r" as"program" mv"direnv* -> direnv"
    zinit light "direnv/direnv"

    path[$path[(i)$ZSH_CONFIG_BASE/compat/python3]]=()
}


__init_zsh_config () {
    __push_paths \
        /opt/homebrew/opt/ambertools/bin \
        ~/.config/zsh/bin \
        ~/.cargo/bin \
        ~/.local/bin

    __init_homebrew
    __init_history
    __init_keybinds
    __init_zinit

    autoload -Uz zmv
    alias zmv='noglob zmv -W'

    autoload -U compinit
    compinit
    zstyle ':completion:*:default' menu select=1

    if __command_exist starship; then
        eval "$(starship init zsh)"
        export STARSHIP_CONFIG=$ZSH_CONFIG_BASE/starship.toml
    fi

    __command_exist exa && alias ls=exa
    
    alias l=ls
    alias la="ls -a"
    alias ll="ls -l"
    alias llh="ls -lh"
    alias lla="ls -la"
    alias lh="ls -lh"

    local vmd=$(setopt NULL_GLOB; echo /Applications/VMD*.app/Contents/Resources/VMD.app/Contents/MacOS/VMD)
    [[ -n "$vmd" ]] && alias vmd="${vmd// /\\ }"

    __command_exist pbpaste && alias p=pbpaste
    __command_exist pbcopy && alias c=pbcopy

    [[ -f /usr/bin/otool ]] && alias ldd="/usr/bin/otool -L"

    __command_exist direnv &&  eval "$(direnv hook zsh)"
}

__init_zsh_config
