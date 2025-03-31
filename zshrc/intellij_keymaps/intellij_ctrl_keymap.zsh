# Pair `ctrl` with right half of keymap
# - `ctrl` is primary
# - `ctrl-shift` is secondary

INTELLIJ_CTRL_NAMESPACE='intellij_ctrl_keymap'
INTELLIJ_CTRL_ALIAS='it'

INTELLIJ_CTRL_KEYMAP=(
	"ctrl-- # Copilot show chat"
	"ctrl-shift-- # Copilot new conversation"
	"ctrl-= # Copilot show completions"
	"ctrl-shift-= # IntelliJ code generate"
	"ctrl-$KEYMAP_ESCAPE # Copilot enable completions"
	"ctrl-shift-$KEYMAP_ESCAPE # Copilot disable completions"
	"ctrl-[ # Copilot show previous completions"
	"ctrl-] # Copilot show next completions"
	"ctrl-[enter] # Copilot apply next word"
	"ctrl-shift-[enter] # Copilot apply next line"
	''
	"ctrl-c # Close tabs to the right"
	"ctrl-shift-c # Close tabs to the left"
	"ctrl-shift-t # Reopen closed tab"
	"ctrl-r # Rename variable in file / file in project"
	"ctrl-shift-r # Rename file"
	''
	"ctrl-d # Delete line (Also in \`intellij_cmd_keymap\`)"
	"ctrl-f # Reformat file"
	"ctrl-g # Toggle case"
	"ctrl-b # To tabs"
	"ctrl-shift-b # To spaces"
	''
	"ctrl-w # Add selection for next occurrence (TextMate)"
	"ctrl-shift-w # Unselect occurrence"
	"ctrl-v # Select all occurrences"
	"ctrl-h # Clone caret above"
	"ctrl-t # Clone caret below"
	"ctrl-m # Multi-column selection mode"
	''
	"ctrl-l # Recent locations"
	"ctrl-z # Last edit location"
	"ctrl-shift-z # Next edit locations"
	"ctrl-n # Next highlighted error"
	"ctrl-shift-n # Previous highlighted error"
	"ctrl-s # Show context actions"
)

keymap_init $INTELLIJ_CTRL_NAMESPACE $INTELLIJ_CTRL_ALIAS "${INTELLIJ_CTRL_KEYMAP[@]}"

function intellij_ctrl_keymap {
	keymap_show $INTELLIJ_CTRL_NAMESPACE $INTELLIJ_CTRL_ALIAS \
		${#INTELLIJ_CTRL_KEYMAP} "${INTELLIJ_CTRL_KEYMAP[@]}" "$@"
}
