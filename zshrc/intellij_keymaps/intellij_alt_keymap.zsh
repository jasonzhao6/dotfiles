# Pair `alt` with left half of keymap
# - `alt` is primary
# - `alt-shift` is secondary

INTELLIJ_ALT_NAMESPACE='intellij_alt_keymap'
INTELLIJ_ALT_ALIAS='ia'

INTELLIJ_ALT_KEYMAP=(
	"alt-c # Copy"
	"alt-v # Paste"
)

keymap_init $INTELLIJ_ALT_NAMESPACE $INTELLIJ_ALT_ALIAS "${INTELLIJ_ALT_KEYMAP[@]}"

function intellij_alt_keymap {
	keymap_invoke $INTELLIJ_ALT_NAMESPACE $INTELLIJ_ALT_ALIAS \
		${#INTELLIJ_ALT_KEYMAP} "${INTELLIJ_ALT_KEYMAP[@]}" "$@"
}
