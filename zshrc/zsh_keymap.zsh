#
# Namespace: [Z]sh
#

ZSH_KEYMAP=(
	'z•e # Edit with IntelliJ'
	'z•m # Edit with TextMate'
	'z•s # Edit secrets'
	''
	'z•z # Source'
	'z•t # Test'
	''
	'z•p # Push from local'
	'z•P # Pull to local'
	''
	'z•a # List aliases'
	'z•a <match> # Filter aliases'
	''
	'z•f # List functions'
	'z•f <match> # Filter functions'
)

function z {
	keymap z ${#ZSH_KEYMAP} "${ZSH_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function za {
	alias | contain "$1"
}

function ze {
	open -na 'IntelliJ IDEA CE.app' --args "$ZSHRC_DIR"
}

function zf {
	# Identify functions by the ` () {` suffix, then trim it
	typeset -f | grep ' () {$' | contain "$1" | trim 0 5
}

function zm {
	mate "$ZSHRC_DIR"
}

ZSH_OTHER_DOTFILES=(
	colordiffrc
	gitignore
	shellcheckrc
	terraformrc
	tm_properties
)

function zp {
	for dotfile in "${ZSH_OTHER_DOTFILES[@]}"; do
		cp "$HOME/.$dotfile" "$DOTFILES_DIR/$dotfile.txt"
	done
}

function zP {
	for dotfile in "${ZSH_OTHER_DOTFILES[@]}"; do
		cp "$DOTFILES_DIR/$dotfile.txt" "$HOME/.$dotfile"
	done
}

function zs {
	mate "$ZSH_SECRETS"
}

function zt {
	zsh "$ZSHRC_DIR"/_tests.zsh "$@"
}

ZSH_SECRETS_DIR="$HOME/Downloads/_Archive/zsh/.zshrc.secrets"
ZSH_SECRETS_LATEST="$ZSH_SECRETS_DIR/latest.txt"

function zz {
	source ~/.zshrc

	# Whenever `ZSH_SECRETS` changes, take a snapshot
	if [[ -f $ZSH_SECRETS ]]; then
		# Create a copy if there is not one already
		[[ ! -f $ZSH_SECRETS_LATEST ]] && cp "$ZSH_SECRETS" "$ZSH_SECRETS_LATEST"

		# Do nothing if the copy is already the latest
		if cmp -s "$ZSH_SECRETS" "$ZSH_SECRETS_LATEST"; then return; fi

		# Otherwise, update the copy and take a snapshot
		cp "$ZSH_SECRETS" "$ZSH_SECRETS_LATEST"
		cp "$ZSH_SECRETS" "$ZSH_SECRETS_DIR/$(date +'%y.%m.%d').txt"
	fi
}
