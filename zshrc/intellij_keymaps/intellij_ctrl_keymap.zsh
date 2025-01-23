# Pair `ctrl` with right half of keymap
# - `ctrl` is primary
# - `ctrl-shift` is secondary

INTELLIJ_CTRL_NAMESPACE='intellij_ctrl_keymap'
INTELLIJ_CTRL_ALIAS='ic'

INTELLIJ_CTRL_KEYMAP=(
	"ctrl-c # Copy"
	"ctrl-v # Paste"
)

keymap_init $INTELLIJ_CTRL_NAMESPACE $INTELLIJ_CTRL_ALIAS "${INTELLIJ_CTRL_KEYMAP[@]}"

function intellij_ctrl_keymap {
	keymap_invoke $INTELLIJ_CTRL_NAMESPACE $INTELLIJ_CTRL_ALIAS \
		${#INTELLIJ_CTRL_KEYMAP} "${INTELLIJ_CTRL_KEYMAP[@]}" "$@"
}
