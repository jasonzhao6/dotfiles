ZSH_NAMESPACE='zsh_keymap'
ZSH_ALIAS='z'
ZSH_DOT="${ZSH_ALIAS}${KEYMAP_DOT}"

ZSH_KEYMAP=(
	"${ZSH_DOT}i # Edit with IntelliJ"
	"${ZSH_DOT}m # Edit with TextMate"
	"${ZSH_DOT}s # Edit secrets"
	"${ZSH_DOT}z # Source"
	"${ZSH_DOT}t # Test"
	''
	"${ZSH_DOT}w # Custom \`which\`"
	"${ZSH_DOT}a # List aliases"
	"${ZSH_DOT}a <match>* <-mismatch>* # Filter aliases"
	"${ZSH_DOT}f # List functions"
	"${ZSH_DOT}f <match>* <-mismatch>* # Filter functions"
	''
	"${ZSH_DOT}h # List history"
	"${ZSH_DOT}h <match>* <-mismatch>* # Filter history"
	"${ZSH_DOT}hc # Clear history"
	"${ZSH_DOT}hm # Edit history file with TextMate"
	''
	"${ZSH_DOT}1 # No session history"
	"${ZSH_DOT}2 # Session history in memory"
	"${ZSH_DOT}0 # Session history in memory & file"
	''
	"${ZSH_DOT}p # Push other dotfiles"
	"${ZSH_DOT}P # Pull other dotfiles"
)

keymap_init $ZSH_NAMESPACE $ZSH_ALIAS "${ZSH_KEYMAP[@]}"

function zsh_keymap {
	keymap_invoke $ZSH_NAMESPACE $ZSH_ALIAS ${#ZSH_KEYMAP} "${ZSH_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function zsh_keymap_0 {
	unset -f zshaddhistory
}

function zsh_keymap_1 {
	function zshaddhistory { return 1; }
}

function zsh_keymap_2 {
	function zshaddhistory { return 2; }
}

function zsh_keymap_a {
	local filters=("$@")

	alias | args_keymap_s "${filters[@]}"
}

function zsh_keymap_f {
	local filters=("$@")

	# Identify functions by the ` () {` suffix, then trim it
	typeset -f | grep ' () {$' | trim 0 5 | args_keymap_s "${filters[@]}"
}

function zsh_keymap_h {
	local filters=("$@")

	cut -c 16- "$HISTFILE" | sort --unique | args_keymap_s "${filters[@]}"
}

function zsh_keymap_hc {
	rm "$HISTFILE"
}

function zsh_keymap_hm {
	mate "$HISTFILE"
}

function zsh_keymap_i {
	open -na 'IntelliJ IDEA CE.app' --args "$ZSHRC_DIR"
}

function zsh_keymap_m {
	mate "$ZSHRC_DIR"
}

ZSH_OTHER_DOTFILES=(
	colordiffrc
	gitignore
	shellcheckrc
	terraformrc
	tm_properties
)

function zsh_keymap_p {
	for dotfile in "${ZSH_OTHER_DOTFILES[@]}"; do
		cp "$HOME/.$dotfile" "$DOTFILES_DIR/$dotfile.txt"
	done
}

function zsh_keymap_P {
	for dotfile in "${ZSH_OTHER_DOTFILES[@]}"; do
		cp "$DOTFILES_DIR/$dotfile.txt" "$HOME/.$dotfile"
	done
}

function zsh_keymap_s {
	mate "$ZSHRC_SECRETS"
}

function zsh_keymap_t {
	zsh "$ZSHRC_DIR"/__tests.zsh "$@"
}

function zsh_keymap_w {
	local program=$1

	local definition; definition=$(which "$program")

	# If `program` in an alias, follow it
	local is_alias=': aliased to ([a-zA-Z0-9_]+)$'
	if [[ $definition =~ $is_alias ]]; then
		echo
		gray_fg "$definition"
		echo

		# shellcheck disable=SC2154 # `match` is defined by `=~`
		definition=$(which "${match[1]}")
	fi

	echo "$definition" | args_keymap_s
}

ZSHRC_SECRETS_DIR="$HOME/Downloads/_Archive/zsh/.zshrc.secrets"
ZSHRC_SECRETS_LATEST="$ZSHRC_SECRETS_DIR/latest.txt"

function zsh_keymap_z {
	source ~/.zshrc

	# Whenever `ZSHRC_SECRETS` changes, take a snapshot
	if [[ -f $ZSHRC_SECRETS ]]; then
		# Create a copy if there is not one already
		[[ ! -f $ZSHRC_SECRETS_LATEST ]] && cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"

		# Do nothing if the copy is already the latest
		if cmp -s "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"; then return; fi

		# Otherwise, update the copy and take a snapshot
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_DIR/$(date +'%y.%m.%d').txt"
	fi
}
