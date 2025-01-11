ZSH_NAMESPACE='zsh_keymap'
ZSH_ALIAS='z'

ZSH_KEYMAP=(
	"$ZSH_ALIAS·i # Edit with IntelliJ"
	"$ZSH_ALIAS·m # Edit with TextMate"
	"$ZSH_ALIAS·s # Edit secrets"
	"$ZSH_ALIAS·z # Source"
	"$ZSH_ALIAS·t # Test"
	''
	"$ZSH_ALIAS·w # Which"
	"$ZSH_ALIAS·a # List aliases"
	"$ZSH_ALIAS·a <match> # Filter aliases"
	"$ZSH_ALIAS·f # List functions"
	"$ZSH_ALIAS·f <match> # Filter functions"
	''
	"$ZSH_ALIAS·h # List history"
	"$ZSH_ALIAS·h <match> # Filter history"
	"$ZSH_ALIAS·hc # Clear history"
	"$ZSH_ALIAS·hm # Edit history file with TextMate"
	"$ZSH_ALIAS·h1 # Do not persist history"
	"$ZSH_ALIAS·h2 # Persist history in memory only"
	"$ZSH_ALIAS·h0 # Persist history in memory & history file"
	''
	"$ZSH_ALIAS·p # Push other dotfiles from local"
	"$ZSH_ALIAS·P # Pull other dotfiles to local"
)

keymap_init $ZSH_NAMESPACE $ZSH_ALIAS "${ZSH_KEYMAP[@]}"

function zsh_keymap {
	keymap_invoke $ZSH_NAMESPACE $ZSH_ALIAS ${#ZSH_KEYMAP} "${ZSH_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function zsh_keymap_a {
	alias | contain "$1"
}

function zsh_keymap_f {
	# Identify functions by the ` () {` suffix, then trim it
	typeset -f | grep ' () {$' | contain "$1" | trim 0 5
}

function zsh_keymap_h {
	local pattern="$*"

	egrep --ignore-case "$pattern" "$HISTFILE" | trim 15 | sort --unique | args_keymap_s
}

function zsh_keymap_hc {
	rm "$HISTFILE"
}

function zsh_keymap_h0 {
	unset -f zshaddhistory
}

function zsh_keymap_h1 {
	function zshaddhistory { return 1; }
}

function zsh_keymap_h2 {
	function zshaddhistory { return 2; }
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
	mate "$ZSH_SECRETS"
}

function zsh_keymap_t {
	zsh "$ZSHRC_DIR"/_tests.zsh "$@"
}

function zsh_keymap_w {
	which "$1" | args_keymap_s
}

ZSH_SECRETS_DIR="$HOME/Downloads/_Archive/zsh/.zshrc.secrets"
ZSH_SECRETS_LATEST="$ZSH_SECRETS_DIR/latest.txt"

function zsh_keymap_z {
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
