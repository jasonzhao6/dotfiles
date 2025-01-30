VIMIUM_NAMESPACE='vimium_keymap'
VIMIUM_ALIAS='v'
VIMIUM_KEYMAP_FILE="$ZSHRC_DIR/${VIMIUM_NAMESPACE}s/$VIMIUM_NAMESPACE.extracted.zsh"

source "$ZSHRC_DIR/${VIMIUM_NAMESPACE}s/vimium_helpers.zsh"
source "$VIMIUM_KEYMAP_FILE"
keymap_init $VIMIUM_NAMESPACE $VIMIUM_ALIAS "${VIMIUM_KEYMAP[@]}"

function vimium_keymap {
	# Extract, source, and init again in case keymap has changed
 	vimium_keymap_extract 'VIMIUM_KEYMAP'
	source "$VIMIUM_KEYMAP_FILE"
	keymap_init $VIMIUM_NAMESPACE $VIMIUM_ALIAS "${VIMIUM_KEYMAP[@]}"

	keymap_invoke $VIMIUM_NAMESPACE $VIMIUM_ALIAS ${#VIMIUM_KEYMAP} "${VIMIUM_KEYMAP[@]}" "$@"
}
