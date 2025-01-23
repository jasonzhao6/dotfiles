# Pair `cmd` with both halves of keymap
# - `cmd` is primary
# - `cmd-shift` is secondary
# - `cmd-alt` is tertiary with left half of keymap
# - `cmd-ctrl` is tertiary with right half of keymap

INTELLIJ_CMD_NAMESPACE='intellij_cmd_keymap'
INTELLIJ_CMD_ALIAS='i'

INTELLIJ_CMD_KEYMAP=(
	"cmd-= # Increase font size in all editors (Convention)"
	"cmd-- # Decrease font size in all editors (Convention)"
	"cmd-0 # Reset font size to 14 (Disabled)"
	''
	"cmd-, # Preferences (Convention)"
	"cmd-p # Select file in project view (TextMate's \`cmd-ctrl-r\`)"
	"cmd-\' # Project drawer (Toggle left panel)" # The extraneous `\` is to make `${(z)}` happy
	"^ cmd-1 # Project files"
	"^ cmd-- # Collapse all"
	"^ cmd-+ # Expand all"
	''
	"cmd-[1-8] # Select tabs #1-8 (Convention)"
	"cmd-9 # Select last tab (Convention)"
	''
	"cmd-alt-1 # Collapse all (TextMate)"
	"cmd-alt-2 # Expand all to level 1"
	"cmd-alt-3 # Expand all to level 2"
	"cmd-alt-4 # Expand all to level 3"
	"cmd-alt-5 # Expand all to level 4"
	"cmd-alt-6 # Expand all to level 5"
	"cmd-alt-0 # Expand all"
	"cmd-alt-\\\` # Expand all (Mac keyboard)" # The extraneous `\` is to make `${(z)}` happy
	"cmd-alt-/ # Expand all (Kinesis keyboard)"
	''
	"cmd-a # Select all (Default)"
	"cmd-shift-[up] # Move caret to text start with selection (Convention)"
	"cmd-shift-[down] # Move caret to text end with selection (Convention)"
	''
	"cmd-ctrl-[up] # Move line up (TextMate)"
	"cmd-ctrl-[down] # Move line down (TextMate)"
	"cmd-ctrl-shift-[up] # Move statement up"
	"cmd-ctrl-shift-[down] # Move statement down"
	"cmd-[ # Indent left (Default)"
	"cmd-] # Indent right (Default)"
	"cmd-/ # Line comment (Convention)"
	"cmd-shift-/ # Block comment"
	''
	"cmd-[esc] # Cyclic expand word (TextMate)"
	"cmd-shift-[esc] # Cyclic expand word backward (TextMate)"
	"cmd-y # Git blame (TextMate)"
	"cmd-shift-y # Resolve conflict"
)

keymap_init $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS "${INTELLIJ_CMD_KEYMAP[@]}"

function intellij_cmd_keymap {
	keymap_invoke $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS \
		${#INTELLIJ_CMD_KEYMAP} "${INTELLIJ_CMD_KEYMAP[@]}" "$@"
}
