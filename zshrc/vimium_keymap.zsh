VIMIUM_NAMESPACE='vimium_keymap'
VIMIUM_ALIAS='v'

VIMIUM_KEYMAP=(
	'c # removeTab'
	'u # duplicateTab'
)

keymap_init $VIMIUM_NAMESPACE $VIMIUM_ALIAS "${VIMIUM_KEYMAP[@]}"

function vimium_keymap {
	keymap_invoke $VIMIUM_NAMESPACE $VIMIUM_ALIAS \
		${#VIMIUM_KEYMAP} "${VIMIUM_KEYMAP[@]}" "$@"
}
