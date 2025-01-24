# Pair `ctrl` with right half of keymap
# - `ctrl` is primary
# - `ctrl-shift` is secondary

INTELLIJ_CTRL_NAMESPACE='intellij_ctrl_keymap'
INTELLIJ_CTRL_ALIAS='ic'

INTELLIJ_CTRL_KEYMAP=(
	"ctrl-- # Copilot show chat"
	"ctrl-shift-- # Copilot new conversation"
	"ctrl-= # Copilot show completions"
	"ctrl-shift-= # IntelliJ code generate"
	"ctrl-$KEYMAP_ESCAPE # Copilot enable completions"
	"ctrl-shift-$KEYMAP_ESCAPE # Copilot disable completions"
	"ctrl-[ # Copilot show previous completions"
	"ctrl-] # Copilot show next completions"
	"ctrl-{enter} # Copilot apply next word"
	"ctrl-shift-{enter} # Copilot apply next line" # TODO use {} b/c they are not on keymap
	''
	"ctrl-c # Close tabs to the right"
	"ctrl-shift-c # Close tabs to the left"
	"ctrl-r # Rename variable in file / file in project"
	"ctrl-shift-r # Rename file"
	''
	"ctrl-f # Reformat file"
	"ctrl-g # Toggle case"
	"ctrl-d # Delete line (Also in \`intellij_cmd_keymap\`)"
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
	''
	"ctrl-b # Toggle line breakpoint (Default: \`cmd-{f8}\`)"
	"ctrl-shift-b # View breakpoints (Default: \`cmd-shift-{f8}\`)"
)

keymap_init $INTELLIJ_CTRL_NAMESPACE $INTELLIJ_CTRL_ALIAS "${INTELLIJ_CTRL_KEYMAP[@]}"

function intellij_ctrl_keymap {
	keymap_invoke $INTELLIJ_CTRL_NAMESPACE $INTELLIJ_CTRL_ALIAS \
		${#INTELLIJ_CTRL_KEYMAP} "${INTELLIJ_CTRL_KEYMAP[@]}" "$@"
}
