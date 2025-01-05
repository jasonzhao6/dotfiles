export ZSHRC_SECRETS_DIR="$HOME/Downloads/_Archive/zsh/.zshrc.secrets"
export ZSHRC_SECRETS_LATEST="$ZSHRC_SECRETS_DIR/latest.txt"

# Source / test
function z { source ~/.zshrc; }
function zz { zsh "$ZSHRC_DIR"/_tests.zsh "$@"; }

# Edit
function zm { mate "$ZSHRC_DIR"; }
function zs { mate "$ZSHRC_SECRETS"; }

# [P]ush other dotfiles
function zp {
	cp ~/.colordiffrc "$DOTFILES_DIR"/colordiffrc.txt
	cp ~/.gitignore "$DOTFILES_DIR"/gitignore.txt
	cp ~/.shellcheckrc "$DOTFILES_DIR"/shellcheckrc.txt
	cp ~/.terraformrc "$DOTFILES_DIR"/terraformrc.txt
	cp ~/.tm_properties "$DOTFILES_DIR"/tm_properties.txt

	if [[ -f $ZSHRC_SECRETS ]]; then
		# Create a new latest copy if there is not one already
		[[ ! -f $ZSHRC_SECRETS_LATEST ]] && cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"

		# Do nothing if the latest copy is still the latest
		if cmp -s "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"; then return; fi

		# Otherwise, update the latest copy and take a snapshot
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_DIR/$(date +'%y.%m.%d').txt"
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
