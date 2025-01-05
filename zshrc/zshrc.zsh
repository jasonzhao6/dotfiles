ZSHRC_SECRETS_SNAPSHOTS="$HOME/Downloads/_Archive/zsh/.zshrc.secrets"
ZSHRC_SECRETS_LATEST="$ZSHRC_SECRETS_SNAPSHOTS/latest.txt"

# Source
function z {
	source ~/.zshrc

	# If `ZSHRC_SECRETS` changed, take a snapshot
	if [[ -f $ZSHRC_SECRETS ]]; then
		# Create a new latest copy if there is not one already
		[[ ! -f $ZSHRC_SECRETS_LATEST ]] && cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"

		# Do nothing if the latest copy is up-to-date
		if cmp -s "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"; then return; fi

		# Otherwise, update the latest copy and take a snapshot
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_SNAPSHOTS/$(date +'%y.%m.%d').txt"
	fi
}

# Test
function zz { zsh "$ZSHRC_DIR"/_tests.zsh "$@"; }

# Edit
function zm { mate "$ZSHRC_DIR"; }
function zs { mate "$ZSHRC_SECRETS"; }

# [P]ull / [p]ush other dotfiles
OTHER_DOTFILES=(colordiffrc gitignore shellcheckrc terraformrc tm_properties)
function zP { for dotfile in "${OTHER_DOTFILES[@]}"; do cp "$DOTFILES_DIR/$dotfile.txt" "$HOME/.$dotfile"; done; }
function zp { for dotfile in "${OTHER_DOTFILES[@]}"; do cp "$HOME/.$dotfile" "$DOTFILES_DIR/$dotfile.txt"; done; }
