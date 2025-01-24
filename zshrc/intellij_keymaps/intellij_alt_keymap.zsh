# Pair `alt` with left half of keymap
# - `alt` is primary
# - `alt-shift` is secondary

INTELLIJ_ALT_NAMESPACE='intellij_alt_keymap'
INTELLIJ_ALT_ALIAS='ia'

# Not that `alt-e/u/i` do not work for some reason
INTELLIJ_ALT_KEYMAP=(
	"alt-a # Sort lines (TextMate: \`[f5]\`)"
	''
	"alt-o # Open on GitHub"
	"alt-shift-o # Overwrite remote"
	''
	"alt-\' # Collapse recursively (TextMate: \`[f1]\`)"
	"alt-, # Collapse (TextMate: \`[f3]\`)"
	"alt-. # Expand (TextMate: \`[f4]\`)"
	"alt-p # Expand recursively (TextMate: \`[f6]\`)"
	''
	"alt-[esc] # Toggle bookmark (\`[f2]\`)"
	"alt-[esc] # Toggle bookmark (\`shift-[f2]\`)"
	"alt-[tab] # Toggle bookmark (\`cmd-[f2]\`)"
	"alt-[tab] # View bookmarks (\`cmd-shift-[f2]\`)"
	"^cmd-a [del] # Delete bookmarks"
	''
	"alt-q # Step over"
	"alt-j # Step into"
	"alt-k # Step out"
	"alt-x # Stop"
	"alt-i # Resume program"
)

keymap_init $INTELLIJ_ALT_NAMESPACE $INTELLIJ_ALT_ALIAS "${INTELLIJ_ALT_KEYMAP[@]}"

function intellij_alt_keymap {
	keymap_invoke $INTELLIJ_ALT_NAMESPACE $INTELLIJ_ALT_ALIAS \
		${#INTELLIJ_ALT_KEYMAP} "${INTELLIJ_ALT_KEYMAP[@]}" "$@"
}
