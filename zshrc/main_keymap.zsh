#
# Namespace: [M]ain
#

MAIN_KEYMAP=(
	'a # Show Args keymap'
	'g # Show Git keymap'
	'k # Show Kubectl keymap'
	't # Show Terraform keymap'
	'w # Show AWS keymap'
	'z # Show Zsh keymap'
	''
	'm·i # Show IntelliJ keymap with `cmd`' # TODO
	'm·ic # Show IntelliJ keymap with `ctrl`'
	'm·ia # Show IntelliJ keymap with `alt`'
	'm·if # Show IntelliJ keymap with `fn`'
	'm·t # Show TextMate keymap'
	''
	'm·k # Show Kinesis keymap'
	''
	'm·v # Show Vimium / Vimari keymap'
)

function m {
	keymap m ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function mv {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
