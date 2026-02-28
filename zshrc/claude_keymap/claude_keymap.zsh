CLAUDE_NAMESPACE='claude_keymap'
CLAUDE_ALIAS='c'
CLAUDE_DOT="${CLAUDE_ALIAS}${KEYMAP_DOT}"

CLAUDE_KEYMAP=(
	"${CLAUDE_DOT}c # Start new session"
	"${CLAUDE_DOT}r # Continue last session"
	"${CLAUDE_DOT}l <match>? # Resume matching session"
	"${CLAUDE_DOT}m # Edit config folder in TextMate"
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
CLAUDE_KEYMAP_FOLDERS=(skills)

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_SRC_DIR/$CLAUDE_NAMESPACE/claude_helpers.zsh"

function claude_keymap_c {
	claude_keymap_check_docker
	claude
}

function claude_keymap_l {
	claude_keymap_check_docker
	claude --resume "$*"
}

function claude_keymap_m {
	mate "$CLAUDE_KEYMAP_TARGET_DIR"
}

function claude_keymap_r {
	claude_keymap_check_docker
	claude --continue
}

function claude_keymap_u {
	echo "Pushing Claude config to 'scratch' repository..."

	rm -rf "$CLAUDE_KEYMAP_SOURCE_DIR"
	mkdir -p "$CLAUDE_KEYMAP_SOURCE_DIR"

	local copy_status=0

	# Copy files; strip leading dot so dot files are visible in scratch repo
	for file in $CLAUDE_KEYMAP_FILES; do
		if [ -f "$CLAUDE_KEYMAP_TARGET_DIR/$file" ]; then
			cp "$CLAUDE_KEYMAP_TARGET_DIR/$file" "$CLAUDE_KEYMAP_SOURCE_DIR/${file#.}" || copy_status=1
		fi
	done

	# Copy folders as-is
	for folder in $CLAUDE_KEYMAP_FOLDERS; do
		if [ -d "$CLAUDE_KEYMAP_TARGET_DIR/$folder" ]; then
			cp -r "$CLAUDE_KEYMAP_TARGET_DIR/$folder" "$CLAUDE_KEYMAP_SOURCE_DIR/" || copy_status=1
		fi
	done

	# Copy ~/.mcp.json as ~mcp.json
	if [ -f "$HOME/.mcp.json" ]; then
		cp "$HOME/.mcp.json" "$CLAUDE_KEYMAP_SOURCE_DIR/~mcp.json" || copy_status=1
	fi

	if [ $copy_status -eq 0 ]; then
		echo "Push operation completed."
	else
		echo "Error: Failed to copy Claude config."
	fi
}

function claude_keymap_U {
	echo "Pulling Claude config from 'scratch' repository..."

	if [ -d "$CLAUDE_KEYMAP_SOURCE_DIR" ]; then
		local copy_status=0

		# Copy files; restore leading dot for dot files
		for file in $CLAUDE_KEYMAP_FILES; do
			if [ -f "$CLAUDE_KEYMAP_SOURCE_DIR/${file#.}" ]; then
				cp "$CLAUDE_KEYMAP_SOURCE_DIR/${file#.}" "$CLAUDE_KEYMAP_TARGET_DIR/$file" || copy_status=1
			fi
		done

		# Copy folders; remove target first so deletions in source are reflected
		for folder in $CLAUDE_KEYMAP_FOLDERS; do
			if [ -d "$CLAUDE_KEYMAP_SOURCE_DIR/$folder" ]; then
				rm -rf "$CLAUDE_KEYMAP_TARGET_DIR/$folder"
				cp -r "$CLAUDE_KEYMAP_SOURCE_DIR/$folder" "$CLAUDE_KEYMAP_TARGET_DIR/" || copy_status=1
			fi
		done

		# Restore ~mcp.json as ~/.mcp.json
		if [ -f "$CLAUDE_KEYMAP_SOURCE_DIR/~mcp.json" ]; then
			cp "$CLAUDE_KEYMAP_SOURCE_DIR/~mcp.json" "$HOME/.mcp.json" || copy_status=1
		fi

		if [ $copy_status -eq 0 ]; then
			echo "Pull operation completed successfully."
		else
			echo "Error: Failed to copy Claude config from 'scratch' repository."
		fi
	else
		echo "Error: 'claude' folder not found in 'scratch' repository."
	fi
}
