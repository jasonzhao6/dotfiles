VIMIUM_SEARCH_NAMESPACE='vimium_search_keymap'
VIMIUM_SEARCH_ALIAS='vv'

source "$ZSHRC_DIR/${VIMIUM_NAMESPACE}s/vimium_helpers.zsh"
vimium_search_keymap_init 'VIMIUM_SEARCH_KEYMAP'

keymap_init $VIMIUM_SEARCH_NAMESPACE $VIMIUM_SEARCH_ALIAS "${VIMIUM_SEARCH_KEYMAP[@]}"

function vimium_search_keymap {
	keymap_invoke $VIMIUM_SEARCH_NAMESPACE $VIMIUM_SEARCH_ALIAS \
		${#VIMIUM_SEARCH_KEYMAP} "${VIMIUM_SEARCH_KEYMAP[@]}" "$@"
}
