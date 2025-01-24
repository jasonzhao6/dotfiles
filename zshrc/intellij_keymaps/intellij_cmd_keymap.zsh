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
	"cmd-n # Create new (Default)"
	"cmd-shift-n # Show scratch files"
	"cmd-alt-n # New scratch file (TextMate)"
	''
	"cmd-t # Go to file (TextMate)"
	"cmd-shift-t # File structure (TextMate)"
	"cmd-u # Go to Declaration or Usages"
	"cmd-shift-u # Find usages"
	"cmd-i # Go to implementation"
	"cmd-shift-c # Copy absolute path"
	"cmd-ctrl-c # Copy path from repository root"
	"cmd-. # Select file in project view (TextMate's \`cmd-ctrl-r\`)"
	''
	"cmd-\' # Project drawer (Toggle left panel)" # The extra `\` is to make `${${(z)...}[1]}` happy
	"^cmd-1 # Project files"
	"^cmd-- # Collapse all"
	"^cmd-+ # Expand all"
	"cmd-\; # Find (Toggle bottom panel)" # The extra `\` is to make `${${(z)...}[1]}` happy
	"cmd-shift-\; # Terminal (Default)" # The extra `\` is to make `${${(z)...}[1]}` happy
	"shift-{esc} # Hide all tool windows (Default)"
	''
	"cmd-{1-8} # Select tabs #1-8 (Convention)"
	"cmd-9 # Select last tab (Convention)"
	''
	"cmd-alt-1 # Collapse all (TextMate)"
	"cmd-alt-2 # Expand all to level 1"
	"cmd-alt-3 # Expand all to level 2"
	"cmd-alt-4 # Expand all to level 3"
	"cmd-alt-5 # Expand all to level 4"
	"cmd-alt-6 # Expand all to level 5"
	"cmd-alt-0 # Expand all"
	"cmd-alt-\` # Expand all (For Mac keyboard)" # The extra `\` is to make `${${(z)...}[1]}` happy
	"cmd-alt-/ # Expand all (For Kinesis keyboard)"
	''
	"cmd-a # Select all (Default)"
	"cmd-shift-{up} # Move caret to text start with selection (Convention)"
	"cmd-shift-{down} # Move caret to text end with selection (Convention)"
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
	"^alt-shift-{enter} # Replace all (\`alt-a\`)"
	"cmd-e # Next occurrence of the word at caret (Convention)"
	"cmd-shift-e # Previous occurrence of the word at caret (Convention)"
	"cmd-g # Find next (Default)"
	"cmd-shift-g # Find previous (Default)"
	''
	"cmd-d # Duplicate entire lines"
	"ctrl-d # Delete line (From \`intellij_ctrl_keymap\`)"
	"cmd-ctrl-{up} # Move line up (TextMate)"
	"cmd-ctrl-{down} # Move line down (TextMate)"
	"cmd-ctrl-shift-{up} # Move statement up"
	"cmd-ctrl-shift-{down} # Move statement down"
	"cmd-[ # Indent left (Default)"
	"cmd-] # Indent right (Default)"
	"cmd-/ # Line comment (Convention)"
	"cmd-shift-/ # Block comment"
	"cmd-j # Join lines"
	''
	"cmd-b # Extend selection (TextMate's \`cmd-shift-b\`)""
	"cmd-shift-b # Shrink selection"
	"cmd-ctrl-b # Move caret to matching brace"
	"cmd-l # Go to line"
	"cmd-shift-l # Extend line selection (TextMate)"
	''
	"cmd-alt-w # Soft-wrap (TextMate)"
	"cmd-{esc} # Cyclic expand word (TextMate)"
	"cmd-shift-{esc} # Cyclic expand word backward (TextMate)"
	''
	"cmd-r # Run"
	"cmd-shift-r # Debug"
	"cmd-ctrl-r # Run with coverage"
	"cmd-ctrl-shift-r # Attach to process"
	"cmd-y # Git blame (TextMate)"
	"cmd-shift-y # Resolve conflict"
	"cmd-k # Find action"
	"shift-shift # Find all"
	''
	"cmd-= # Increase font size in all editors (Convention)"
	"cmd-- # Decrease font size in all editors (Convention)"
	"cmd-0 # Reset font size to 14 (Disabled)"
	"cmd-o # Manage projects (Convention)"
	"cmd-, # Preferences (Convention)"
	"cmd-h # Hide window (Default)"
	"cmd-m # Minimize window (Default)"
	"cmd-s # Save (Implicit)"
	"cmd-q # Quit (Default)"
	''
	"cmd-w # Close active tab (Default)"
	"cmd-ctrl-w # Close other tabs (TextMate)"
	"cmd-ctrl-alt-w # Close all tabs (TextMate)"
	"cmd-shift-w # Close project (TextMate)"
)

keymap_init $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS "${INTELLIJ_CMD_KEYMAP[@]}"

function intellij_cmd_keymap {
	keymap_invoke $INTELLIJ_CMD_NAMESPACE $INTELLIJ_CMD_ALIAS \
		${#INTELLIJ_CMD_KEYMAP} "${INTELLIJ_CMD_KEYMAP[@]}" "$@"
}
