ZSH_NAMESPACE='zsh_keymap'
ZSH_ALIAS='z'
ZSH_DOT="${ZSH_ALIAS}${KEYMAP_DOT}"

ZSH_KEYMAP=(
	"${ZSH_DOT}e # Edit in IntelliJ"
	"${ZSH_DOT}m # Edit in TextMate"
	"${ZSH_DOT}mm # Edit secrets in TextMate"
	"${ZSH_DOT}s # Source"
	"${ZSH_DOT}t # Test"
	''
	"${ZSH_DOT}z <name> # Custom \`which\` lookup"
	"${ZSH_DOT}a # List aliases"
	"${ZSH_DOT}a <match>* <-mismatch>* # Filter aliases"
	"${ZSH_DOT}f # List functions"
	"${ZSH_DOT}f <match>* <-mismatch>* # Filter functions"
	''
	"${ZSH_DOT}h <grep>? # List history"
	"${ZSH_DOT}hc # Clear history"
	"${ZSH_DOT}hm # Edit history file in TextMate"
	''
	"${ZSH_DOT}1 # No session history"
	"${ZSH_DOT}2 # Session history in memory"
	"${ZSH_DOT}0 # Session history in memory & file"
	''
	"${ZSH_DOT}p # Push other dotfiles to this repo"
	"${ZSH_DOT}P # Pull other dotfiles from this repo"
)

keymap_init $ZSH_NAMESPACE $ZSH_ALIAS "${ZSH_KEYMAP[@]}"

function zsh_keymap {
	keymap_show $ZSH_NAMESPACE $ZSH_ALIAS ${#ZSH_KEYMAP} "${ZSH_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_SRC_DIR/$ZSH_NAMESPACE/zsh_helpers.zsh"

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

function zsh_keymap_e {
	open -na 'IntelliJ IDEA.app' --args "$DOTFILES_DIR"
}

function zsh_keymap_f {
	local filters=("$@")

	# Identify functions by the ` () {` suffix, then trim it
	typeset -f | egrep '^\S+ \() {$' | trim 0 5 | args_keymap_s "${filters[@]}"
}

function zsh_keymap_h {
	local match="$*"

	cut -c 16- "$HISTFILE" | sort --unique | grep "$match" | as
}

function zsh_keymap_hc {
	rm "$HISTFILE"
}

function zsh_keymap_hm {
	mate "$HISTFILE"
}

function zsh_keymap_m {
	mate "$DOTFILES_DIR"
}

function zsh_keymap_mm {
	mate "$ZSHRC_SECRETS"
}

ZSH_OTHER_DOTFILES=(
	colordiffrc
	gitignore
	shellcheckrc
	terraformrc
	tm_properties
)

ZSHRC_SECRETS_DIR="$HOME/Documents/-backups/zsh.secrets"
ZSHRC_SECRETS_LATEST="$ZSHRC_SECRETS_DIR/latest.txt"

function zsh_keymap_p {
	for dotfile in "${ZSH_OTHER_DOTFILES[@]}"; do
		cp "$HOME/.$dotfile" "$DOTFILES_DIR/$dotfile.txt"
	done

	# Whenever `ZSHRC_SECRETS` changes, take a snapshot
	if [[ -f $ZSHRC_SECRETS ]]; then
		# Create a copy if there is not one already
		[[ ! -f $ZSHRC_SECRETS_LATEST ]] && cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"

		# Do nothing if the copy is already the latest
		if cmp --silent "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"; then return; fi

		# Otherwise, update the copy and take a snapshot
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_LATEST"
		cp "$ZSHRC_SECRETS" "$ZSHRC_SECRETS_DIR/$(date +'%y.%m.%d').txt"
	fi
}

function zsh_keymap_P {
	for dotfile in "${ZSH_OTHER_DOTFILES[@]}"; do
		cp "$DOTFILES_DIR/$dotfile.txt" "$HOME/.$dotfile"
	done

	cp "$ZSHRC_SECRETS_LATEST" "$ZSHRC_SECRETS"
}

function zsh_keymap_s {
	source ~/.zshrc
}

function zsh_keymap_t {
	zsh "$ZSHRC_SRC_DIR"/_tests.zsh "$@"
}

function zsh_keymap_z {
	local name=$1
	[[ -z $name ]] && echo && red_bar 'name required' && return

	# Verify that name exists
	local definition; definition=$(which "$name")
	[[ $definition == "$name not found" ]] && echo && red_bar "\`$name\` not found" && return

	# Prepare regex to match keys in keymaps
	local key_regex; key_regex="^${name:0:1}[.]${name:1} "

	echo

	# If `name` is a zsh alias, show the alias definition
	local is_alias="^$name: aliased to (.+)$"
	if [[ $definition =~ $is_alias ]]; then
		gray_fg "  # \`${definition/: aliased to /\` is aliased to \`}\`"

		# If the zsh alias is a keymap key, show its usage
		if zsh_keymap_does_key_exist "$key_regex"; then
			eval "${name:0:1} '$key_regex'"
	 	fi
		echo

		# shellcheck disable=SC2154 # `match` is defined by `=~`
		definition=$(which "${match[1]}")
	fi

	echo "$definition" | args_keymap_s
}
