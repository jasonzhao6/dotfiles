CLAUDE_NAMESPACE='claude_keymap'
CLAUDE_ALIAS='c'
CLAUDE_DOT="${CLAUDE_ALIAS}${KEYMAP_DOT}"

CLAUDE_KEYMAP=(
	"${CLAUDE_DOT}c # Start new session"
	"${CLAUDE_DOT}r # Continue last session"
	"${CLAUDE_DOT}l <match>? # Resume matching session"
	"${CLAUDE_DOT}u # Push config to \`scratch\` repo (not \`p\` b/c \`cp\` is reserved)"
	"${CLAUDE_DOT}U # Pull config from \`scratch\` repo"
)

keymap_init $CLAUDE_NAMESPACE $CLAUDE_ALIAS "${CLAUDE_KEYMAP[@]}"

function claude_keymap {
	keymap_show $CLAUDE_NAMESPACE $CLAUDE_ALIAS ${#CLAUDE_KEYMAP} "${CLAUDE_KEYMAP[@]}" "$@"
}

CLAUDE_KEYMAP_SOURCE_DIR="$HOME/GitHub/jasonzhao6/scratch/claude"
CLAUDE_KEYMAP_TARGET_DIR="$HOME/.claude"
CLAUDE_KEYMAP_FILES=(CLAUDE.md settings.json)

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

function claude_keymap_u {
	echo "Pushing Claude config to 'scratch' repository..."

	if [ -d "$CLAUDE_KEYMAP_SOURCE_DIR" ]; then
		rm -rf "$CLAUDE_KEYMAP_SOURCE_DIR"
		mkdir -p "$CLAUDE_KEYMAP_SOURCE_DIR"

		local copy_status=0
		for file in $CLAUDE_KEYMAP_FILES; do
			if [ -f "$CLAUDE_KEYMAP_TARGET_DIR/$file" ]; then
				cp "$CLAUDE_KEYMAP_TARGET_DIR/$file" "$CLAUDE_KEYMAP_SOURCE_DIR/" || copy_status=1
			fi
		done

		if [ $copy_status -eq 0 ]; then
			echo "Push operation completed."
		else
			echo "Error: Failed to copy Claude config."
		fi
	else
		echo "Error: 'claude' folder not found in 'scratch' repository."
	fi
}

function claude_keymap_U {
	echo "Pulling Claude config from 'scratch' repository..."

	if [ -d "$CLAUDE_KEYMAP_SOURCE_DIR" ]; then
		local copy_status=0
		for file in $CLAUDE_KEYMAP_FILES; do
			if [ -f "$CLAUDE_KEYMAP_SOURCE_DIR/$file" ]; then
				cp "$CLAUDE_KEYMAP_SOURCE_DIR/$file" "$CLAUDE_KEYMAP_TARGET_DIR/" || copy_status=1
			fi
		done

		if [ $copy_status -eq 0 ]; then
			echo "Pull operation completed successfully."
		else
			echo "Error: Failed to copy Claude config from 'scratch' repository."
		fi
	else
		echo "Error: 'claude' folder not found in 'scratch' repository."
	fi
}
