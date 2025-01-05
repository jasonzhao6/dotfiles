# Source / test
function z { source ~/.zshrc; }
function zz { zsh "$ZSHRC_DIR"/_tests.zsh "$@"; }

# Edit
function zm { mate "$ZSHRC_DIR"; }
function zs { mate ~/.zshrc.secrets; }

# [P]ush other dotfiles
function zp {
    cp ~/.colordiffrc "$DOTFILES_DIR"/colordiffrc.txt
    cp ~/.gitignore "$DOTFILES_DIR"/gitignore.txt
    cp ~/.shellcheckrc "$DOTFILES_DIR"/shellcheckrc.txt
    cp ~/.terraformrc "$DOTFILES_DIR"/terraformrc.txt
    cp ~/.tm_properties "$DOTFILES_DIR"/tm_properties.txt

    if [[ -f ~/.zshrc.secrets ]]; then
        openssl sha1 ~/.zshrc.secrets > ~/.zshrc.secrets_sha1_candidate

        if diff ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1 > /dev/null 2>&1; then
            cp ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1
            cp ~/.zshrc.secrets ~/Downloads/\>\ Archive/zsh/.zshrc.secrets/"$(date +'%y.%m.%d')".txt
        fi
    fi
}

#[P]ull other dotfiles
function zP {
    cp "$DOTFILES_DIR"/colordiffrc.txt ~/.colordiffrc
    cp "$DOTFILES_DIR"/gitignore.txt ~/.gitignore
    cp "$DOTFILES_DIR"/shellcheckrc.txt ~/.shellcheckrc
    cp "$DOTFILES_DIR"/terraformrc.txt ~/.terraformrc
    cp "$DOTFILES_DIR"/tm_properties.txt ~/.tm_properties
}
