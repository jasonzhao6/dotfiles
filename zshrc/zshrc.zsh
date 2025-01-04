# shellcheck source=/dev/null

[[ -z $ZSHRC_UNDER_TEST && -f ~/.zshrc.secrets ]] && source ~/.zshrc.secrets

# Source / test
function z { source ~/.zshrc; }
function zz { zsh "$ZSHRC_DIR"/_tests.zsh "$@"; }

# Edit
function zm { mate "$ZSHRC_DIR"; }
function zs { mate ~/.zshrc.secrets; }

# [U]pload other dotfiles
function zu {
    cp ~/.colordiffrc "$ZSHRC_DIR"/colordiffrc.txt
    cp ~/.gitignore "$ZSHRC_DIR"/gitignore.txt
    cp ~/.terraformrc "$ZSHRC_DIR"/terraformrc.txt
    cp ~/.tm_properties "$ZSHRC_DIR"/tm_properties.txt

    if [[ -f ~/.zshrc.secrets ]]; then
        openssl sha1 ~/.zshrc.secrets > ~/.zshrc.secrets_sha1_candidate

        if diff ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1 > /dev/null 2>&1; then
            cp ~/.zshrc.secrets_sha1_candidate ~/.zshrc.secrets_sha1
            cp ~/.zshrc.secrets ~/Downloads/\>\ Archive/zsh/.zshrc.secrets/"$(date +'%y.%m.%d')".txt
        fi
    fi
}

#[D]ownload other dotfiles
function zd {
    cp "$ZSHRC_DIR"/colordiffrc.txt ~/.colordiffrc
    cp "$ZSHRC_DIR"/gitignore.txt ~/.gitignore
    cp "$ZSHRC_DIR"/terraformrc.txt ~/.terraformrc
    cp "$ZSHRC_DIR"/tm_properties.txt ~/.tm_properties
}
