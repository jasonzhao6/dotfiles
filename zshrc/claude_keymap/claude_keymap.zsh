CLAUDE_NAMESPACE='claude_keymap'
CLAUDE_ALIAS='c'
CLAUDE_DOT="${CLAUDE_ALIAS}${KEYMAP_DOT}"

CLAUDE_KEYMAP=(
	"${CLAUDE_DOT}c # Start new session"
	"${CLAUDE_DOT}r # Continue last session"
	"${CLAUDE_DOT}l <match>? # Resume matching session"
)

keymap_init $CLAUDE_NAMESPACE $CLAUDE_ALIAS "${CLAUDE_KEYMAP[@]}"

function claude_keymap {
	keymap_show $CLAUDE_NAMESPACE $CLAUDE_ALIAS ${#CLAUDE_KEYMAP} "${CLAUDE_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function claude_keymap_c {
	claude
}

function claude_keymap_l {
	claude --resume "$*"
}

function claude_keymap_r {
	claude --continue
}
