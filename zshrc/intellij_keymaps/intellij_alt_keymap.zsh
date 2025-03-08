# Pair `alt` with left half of keymap
# - `alt` is primary
# - `alt-shift` is secondary

INTELLIJ_ALT_NAMESPACE='intellij_alt_keymap'
INTELLIJ_ALT_ALIAS='ia'

# Note that `alt-e/u` do not work for some reason
# Note that `[' ` ;]` require escaping to make `${${(z)...}[1]}` happy
INTELLIJ_ALT_KEYMAP=(
	"alt-a # Sort lines (TextMate: \`{F5}\`)"
	"alt-shift-a # Reverse lines"
	''
	"alt-o # Open on GitHub"
	"alt-shift-o # Overwrite remote"
	''
	"alt-\' # Collapse recursively (TextMate: \`{F1}\`)"
	"alt-, # Collapse (\`{F3}\`)"
	"alt-. # Expand (\`{F4}\`)"
	"alt-p # Expand recursively (\`{F6}\`)"
	''
	"alt-{tab} # Toggle bookmark (\`cmd-{F2}\`)"
	"alt-{tab} # View bookmarks (\`cmd-shift-{F2}\`)"
	"^cmd-a {del} # Delete bookmarks"
	"alt-{esc} # Next line bookmark (TextMate: \`{F2}\`)"
	"alt-{esc} # Previous line bookmark (\`shift-{F2}\`)"
	''
	"alt-\; # Toggle line breakpoint (Default: \`cmd-{F8}\`)"
	"alt-shift-\; # View breakpoints (Default: \`cmd-shift-{F8}\`)"
	"alt-q # Step over"
	"alt-j # Step into"
	"alt-k # Step out"
	"alt-x # Stop"
	"alt-i # Resume program"
)

keymap_init $INTELLIJ_ALT_NAMESPACE $INTELLIJ_ALT_ALIAS "${INTELLIJ_ALT_KEYMAP[@]}"

function intellij_alt_keymap {
	keymap_show $INTELLIJ_ALT_NAMESPACE $INTELLIJ_ALT_ALIAS \
		${#INTELLIJ_ALT_KEYMAP} "${INTELLIJ_ALT_KEYMAP[@]}" "$@"
}
