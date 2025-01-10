MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'

MAIN_KEYMAP=(
	'a # Show Args keymap' # TODO generate `find . -maxdepth 2 -name '*_keymap.zsh'`
	'g # Show Git keymap'
	'k # Show Kubectl keymap'
	't # Show Terraform keymap'
	'w # Show AWS keymap'
	'z # Show Zsh keymap'
	''
	"$MAIN_ALIAS·i # Show IntelliJ keymap with \`cmd\`" # TODO
	"$MAIN_ALIAS·ic # Show IntelliJ keymap with \`ctrl\`"
	"$MAIN_ALIAS·ia # Show IntelliJ keymap with \`alt\`"
	"$MAIN_ALIAS·if # Show IntelliJ keymap with \`fn\`"
	"$MAIN_ALIAS·t # Show TextMate keymap"
	''
	"$MAIN_ALIAS·k # Show Kinesis keymap"
	''
	"$MAIN_ALIAS·b # Show browser keymap (Vimium / Vimari)"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function main_keymap_b {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
