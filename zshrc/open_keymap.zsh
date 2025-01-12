#
# Namespace: [O]pen # TODO
#

OPEN_KEYMAP=(
	'o$KEYMAP_DOT'
)

function o {
#	keymap o ${#OPEN_KEYMAP} "${OPEN_KEYMAP[@]}" "$@"
	cat "$DOTFILES_DIR"/vimium/vimium-searches.txt
}

#
# Key mappings (Alphabetized)
#

# TODO pbcopy, pbpaste
