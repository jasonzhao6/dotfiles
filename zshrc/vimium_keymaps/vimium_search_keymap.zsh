VIMIUM_SEARCH_NAMESPACE='vimium_search_keymap'
VIMIUM_SEARCH_ALIAS='v'
VIMIUM_SEARCH_KEYMAP_FILE="$ZSHRC_SRC_DIR/${VIMIUM_NAMESPACE}s/$VIMIUM_SEARCH_NAMESPACE.extracted.zsh"

source "$ZSHRC_SRC_DIR/${VIMIUM_NAMESPACE}s/vimium_search_helpers.zsh"
source "$VIMIUM_SEARCH_KEYMAP_FILE"

keymap_init $VIMIUM_SEARCH_NAMESPACE $VIMIUM_SEARCH_ALIAS "${VIMIUM_SEARCH_KEYMAP[@]}"

function vimium_search_keymap {
	# Extract, source, and init again in case keymap has changed
	vimium_search_keymap_extract 'VIMIUM_SEARCH_KEYMAP'
	source "$VIMIUM_SEARCH_KEYMAP_FILE"
	keymap_init $VIMIUM_SEARCH_NAMESPACE $VIMIUM_SEARCH_ALIAS "${VIMIUM_SEARCH_KEYMAP[@]}"

	keymap_show $VIMIUM_SEARCH_NAMESPACE $VIMIUM_SEARCH_ALIAS \
		${#VIMIUM_SEARCH_KEYMAP} "${VIMIUM_SEARCH_KEYMAP[@]}" "$@"
}
