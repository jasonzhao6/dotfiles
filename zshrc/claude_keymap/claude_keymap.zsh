CLAUDE_NAMESPACE='claude_keymap'
CLAUDE_ALIAS='c'
CLAUDE_DOT="${CLAUDE_ALIAS}${KEYMAP_DOT}"

CLAUDE_KEYMAP=(
	"${CLAUDE_DOT}c # Start new session"
	"${CLAUDE_DOT}r # Continue last session"
	"${CLAUDE_DOT}l <match>? # Resume matching session"
	"${CLAUDE_DOT}t # Start Claude in scratch repo"
	"${CLAUDE_DOT}m # Edit config folder in TextMate"
	"${CLAUDE_DOT}o # Print project's local settings"
	"${CLAUDE_DOT}oo # Move project's local permissions to global settings"
	"${CLAUDE_DOT}u # Push config to \`scratch\` repo (not \`p\` b/c \`cp\` is reserved)"
	"${CLAUDE_DOT}U # Pull config from \`scratch\` repo"
)

keymap_init $CLAUDE_NAMESPACE $CLAUDE_ALIAS "${CLAUDE_KEYMAP[@]}"

function claude_keymap {
	keymap_show $CLAUDE_NAMESPACE $CLAUDE_ALIAS ${#CLAUDE_KEYMAP} "${CLAUDE_KEYMAP[@]}" "$@"
}

CLAUDE_KEYMAP_SCRATCH_DIR="$HOME/GitHub/jasonzhao6/scratch/claude"
CLAUDE_KEYMAP_CONFIG_DIR="$HOME/.claude"
CLAUDE_KEYMAP_FILES=(CLAUDE.md settings.json settings.local.json)
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
	mate "$CLAUDE_KEYMAP_CONFIG_DIR"
}

function claude_keymap_o {
	local local_settings='.claude/settings.local.json'

	if [ -f "$local_settings" ]; then
		cat "$local_settings"
	else
		red_bar "No local settings"
	fi
}

function claude_keymap_oo {
	local local_settings='.claude/settings.local.json'
	local global_settings="$CLAUDE_KEYMAP_CONFIG_DIR/settings.json"

	if [ ! -f "$local_settings" ]; then
		red_bar "No local settings"
		return 1
	fi

	# Extract local permissions
	local local_perms
	local_perms=$(jq -r '.permissions.allow // [] | .[]' "$local_settings" 2>/dev/null)

	if [ -z "$local_perms" ]; then
		red_bar "No local permissions"
		return 1
	fi

	# Merge local permissions into global settings
	jq --argjson new "$(jq '.permissions.allow // []' "$local_settings")" \
		'.permissions.allow = ([.permissions.allow // [], $new] | flatten | unique | sort)' \
		"$global_settings" > "${global_settings}.tmp" &&
		mv "${global_settings}.tmp" "$global_settings"

	# Remove permissions from local settings
	local updated
	updated=$(jq 'del(.permissions.allow) | if .permissions == {} then del(.permissions) else . end' "$local_settings")

	if [ "$(echo "$updated" | jq 'length')" -eq 0 ]; then
		rm "$local_settings"
		green_bar "Moved to global"
	else
		echo "$updated" > "$local_settings"
		green_bar "Moved to global; kept local"
	fi

	# Push updated global config to scratch repo
	echo
	claude_keymap_u
}

function claude_keymap_r {
	claude_keymap_check_docker
	claude --continue
}

function claude_keymap_t {
	# Save current background color, then tint the tab blue to signal scratch mode
	local original_bg
	original_bg=$(osascript -e 'tell application "Terminal" to get background color of selected tab of front window')
	osascript -e '
		tell application "Terminal"
			set bg to background color of selected tab of front window
			set item 3 of bg to (item 3 of bg) + 5000
			set background color of selected tab of front window to bg
		end tell'

	cd "$HOME/GitHub/jasonzhao6/scratch"
	# Notify Terminal.app of new cwd so Claude's tab title shows 'scratch'
	printf '\e]7;file://%s%s\a' "$HOST" "$PWD"
	claude_keymap_c

	# Restore original background color
	osascript -e "tell application \"Terminal\" to set background color of selected tab of front window to {$original_bg}"
}

function claude_keymap_u {
	echo "Pushing Claude config to 'scratch' repository..."

	rm -rf "$CLAUDE_KEYMAP_SCRATCH_DIR"
	mkdir -p "$CLAUDE_KEYMAP_SCRATCH_DIR"

	local copy_status=0

	# Copy files; strip leading dot so dot files are visible in scratch repo
	for file in $CLAUDE_KEYMAP_FILES; do
		if [ -f "$CLAUDE_KEYMAP_CONFIG_DIR/$file" ]; then
			cp "$CLAUDE_KEYMAP_CONFIG_DIR/$file" "$CLAUDE_KEYMAP_SCRATCH_DIR/${file#.}" || copy_status=1
		fi
	done

	# Copy folders as-is
	for folder in $CLAUDE_KEYMAP_FOLDERS; do
		if [ -d "$CLAUDE_KEYMAP_CONFIG_DIR/$folder" ]; then
			cp -r "$CLAUDE_KEYMAP_CONFIG_DIR/$folder" "$CLAUDE_KEYMAP_SCRATCH_DIR/" || copy_status=1
		fi
	done

	# Copy ~/.mcp.json as ~mcp.json
	if [ -f "$HOME/.mcp.json" ]; then
		cp "$HOME/.mcp.json" "$CLAUDE_KEYMAP_SCRATCH_DIR/~mcp.json" || copy_status=1
	fi

	if [ $copy_status -eq 0 ]; then
		echo "Push operation completed."
	else
		echo "Error: Failed to copy Claude config."
	fi
}

function claude_keymap_U {
	echo "Pulling Claude config from 'scratch' repository..."

	if [ -d "$CLAUDE_KEYMAP_SCRATCH_DIR" ]; then
		local copy_status=0

		# Copy files; restore leading dot for dot files
		for file in $CLAUDE_KEYMAP_FILES; do
			if [ -f "$CLAUDE_KEYMAP_SCRATCH_DIR/${file#.}" ]; then
				cp "$CLAUDE_KEYMAP_SCRATCH_DIR/${file#.}" "$CLAUDE_KEYMAP_CONFIG_DIR/$file" || copy_status=1
			fi
		done

		# Copy folders; remove target first so deletions in source are reflected
		for folder in $CLAUDE_KEYMAP_FOLDERS; do
			if [ -d "$CLAUDE_KEYMAP_SCRATCH_DIR/$folder" ]; then
				rm -rf "$CLAUDE_KEYMAP_CONFIG_DIR/$folder"
				cp -r "$CLAUDE_KEYMAP_SCRATCH_DIR/$folder" "$CLAUDE_KEYMAP_CONFIG_DIR/" || copy_status=1
			fi
		done

		# Restore ~mcp.json as ~/.mcp.json
		if [ -f "$CLAUDE_KEYMAP_SCRATCH_DIR/~mcp.json" ]; then
			cp "$CLAUDE_KEYMAP_SCRATCH_DIR/~mcp.json" "$HOME/.mcp.json" || copy_status=1
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
