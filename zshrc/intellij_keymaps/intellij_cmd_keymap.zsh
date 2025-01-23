# Pair `cmd` with both halves of keymap
# - `cmd` is primary
# - `cmd-shift` is secondary
# - `cmd-alt` is tertiary with left half of keymap
# - `cmd-alt-shift` is quaternary with left half of keymap
# - `cmd-ctrl` is tertiary with right half of keymap
# - `cmd-ctrl-shift` is Quaternary with right half of keymap

INTELLIJ_CMD_NAMESPACE='intellij_cmd_keymap'
INTELLIJ_CMD_ALIAS='i'

INTELLIJ_CMD_KEYMAP=(
	"cmd-\' # Project drawer (Toggle left panel)" # The extraneous `\` is to make `${(z)}` happy
	"^cmd-1 # Project files"
	"^cmd-- # Collapse all"
	"^cmd-+ # Expand all"
	"cmd-\; # Find (Toggle bottom panel)" # The extraneous `\` is to make `${(z)}` happy
	"cmd-shift-\; # Terminal (Default)" # The extraneous `\` is to make `${(z)}` happy
	''
	"cmd-n # Create new (Default)"
	"cmd-shift-n # Show scratch files"
	"cmd-alt-n # New scratch file (TextMate)"
	''
	"cmd-= # Increase font size in all editors (Convention)"
	"cmd-- # Decrease font size in all editors (Convention)"
	"cmd-0 # Reset font size to 14 (Disabled)"
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
	"cmd-t # Go to file (TextMate)"
	"cmd-shift-t # File structure (TextMate)"
	"cmd-u # Go to Declaration or Usages"
	"cmd-shift-u # Find usages"
	"cmd-i # Go to implementation"
	"cmd-k # Find action"
	''
	"cmd-shift-c # Copy absolute path"
	"cmd-ctrl-c # Copy path from repository root"
	"cmd-. # Select file in project view (TextMate's \`cmd-ctrl-r\`)"
	''
	"cmd-a # Select all (Default)"
	"cmd-shift-[up] # Move caret to text start with selection (Convention)"
	"cmd-shift-[down] # Move caret to text end with selection (Convention)"
	"cmd-c # Copy (Default)"
	"cmd-x # Cut (Default)"
	"cmd-v # Paste (Default)"
	"cmd-z # Undo (Default)"
	"cmd-shift-z # Redo (Default)"
	''
	"cmd-f # Find (Default)"
	"cmd-ctrl-f # Replace"
	"cmd-shift-f # Find in files (TextMate)"
	"cmd-ctrl-shift-f # Replace in files"
	"^alt-shift-[enter] # Replace all"
	"^alt-a # Replace all"
	''
	"cmd-e # Next occurrence of the word at caret (Convention)"
	"cmd-shift-e # Previous occurrence of the word at caret (Convention)"
	"cmd-g # Find next (Default)"
	"cmd-shift-g # Find previous (Default)"
	''
	"cmd-d # Duplicate entire lines"
	"cmd-shift-d # Delete line (\`ctrl-d\`)"
	"cmd-ctrl-[up] # Move line up (TextMate)"
	"cmd-ctrl-[down] # Move line down (TextMate)"
	"cmd-ctrl-shift-[up] # Move statement up"
	"cmd-ctrl-shift-[down] # Move statement down"
	"cmd-/ # Line comment (Convention)"
	"cmd-shift-/ # Block comment"
	"cmd-[ # Indent left (Default)"
	"cmd-] # Indent right (Default)"
	"cmd-j # Join lines"
	''
	"cmd-b # Extend selection"
	"cmd-shift-b # Shrink selection"
	"cmd-ctrl-b # Move caret to matching brace"
	"cmd-l # Go to line"
	"cmd-shift-l # Extend line selection (TextMate)"
	''
	"cmd-[esc] # Cyclic expand word (TextMate)"
	"cmd-shift-[esc] # Cyclic expand word backward (TextMate)"
	''
	"cmd-r # Run"
	"cmd-shift-r # Debug"
	"cmd-ctrl-r # Run with coverage"
	"cmd-ctrl-shift-r # Stop"
	"cmd-y # Git blame (TextMate)"
	"cmd-shift-y # Resolve conflict"
	''
	"cmd-o # Manage projects (Convention)"
	"cmd-, # Preferences (Convention)"
	"cmd-h # Hide window (Default)"
	"cmd-m # Minimize window (Default)"
	"cmd-w # Close active tab (Default)"
	"cmd-ctrl-w # Close other tabs (TextMate)"
	"cmd-ctrl-alt-w # Close all tabs (TextMate)"
	"cmd-shift-w # Close project (TextMate)"
	"cmd-s # Save (Default)"
	"cmd-q # Quit (Default)"
)

keymap_init $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS "${INTELLIJ_CMD_KEYMAP[@]}"

function intellij_cmd_keymap {
	keymap_invoke $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS \
		${#INTELLIJ_CMD_KEYMAP} "${INTELLIJ_CMD_KEYMAP[@]}" "$@"
}
