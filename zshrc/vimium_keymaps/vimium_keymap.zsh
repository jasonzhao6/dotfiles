VIMIUM_NAMESPACE='vimium_keymap'
VIMIUM_ALIAS='v'

source "$ZSHRC_DIR/${VIMIUM_NAMESPACE}s/vimium_helpers.zsh"
vimium_keymap_init 'VIMIUM_KEYMAP'

keymap_init $VIMIUM_NAMESPACE $VIMIUM_ALIAS "${VIMIUM_KEYMAP[@]}"

function vimium_keymap {
	keymap_invoke $VIMIUM_NAMESPACE $VIMIUM_ALIAS \
		${#VIMIUM_KEYMAP} "${VIMIUM_KEYMAP[@]}" "$@"
}
