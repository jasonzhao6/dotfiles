# Pair `cmd` with both halves of keymap
# - `cmd` is primary
# - `cmd-shift` is secondary
# - `cmd-alt` is tertiary with left half of keymap
# - `cmd-ctrl` is tertiary with right half of keymap

INTELLIJ_CMD_NAMESPACE='intellij_cmd_keymap'
INTELLIJ_CMD_ALIAS='i'

INTELLIJ_CMD_KEYMAP=(
	"cmd-= # Increase font size in all editors (convention)"
	"cmd-- # Decrease font size in all editors (convention)"
	''
	"cmd-[ # Indent left (default)"
	"cmd-] # Indent right (default)"
	"cmd-/ # Line comment (convention)"
	"cmd-shift-/ # Block comment"
	''
)

keymap_init $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS "${INTELLIJ_CMD_KEYMAP[@]}"

function intellij_cmd_keymap {
	keymap_invoke $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS \
		${#INTELLIJ_CMD_KEYMAP} "${INTELLIJ_CMD_KEYMAP[@]}" "$@"
}
