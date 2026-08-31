CLAUDE_NAMESPACE='claude_keymap'
CLAUDE_ALIAS='c'
CLAUDE_DOT="${CLAUDE_ALIAS}${KEYMAP_DOT}"

CLAUDE_KEYMAP=(
	''
	"${CLAUDE_DOT}c # Start new session"
	"${CLAUDE_DOT}r # Resume last session"
	"${CLAUDE_DOT}l <match>? # List matching sessions"
	''
	"${CLAUDE_DOT}s # Start scratch session"
	"${CLAUDE_DOT}ss # Reset tab background color"
	"${CLAUDE_DOT}n # Start new 5-hour token window"
	''
	"${CLAUDE_DOT}m # Edit config folder in TextMate"
	"${CLAUDE_DOT}P # Push config to \`scratch\` (\`cp\` reserved)"
	"${CLAUDE_DOT}PP # Pull config from \`scratch\` repo"
	''
	"${CLAUDE_DOT}d # (Reserved: Change directory)"
	"${CLAUDE_DOT}p # (Reserved: Copy files)"
)

keymap_init $CLAUDE_NAMESPACE $CLAUDE_ALIAS "${CLAUDE_KEYMAP[@]}"

function claude_keymap {
	keymap_show $CLAUDE_NAMESPACE $CLAUDE_ALIAS ${#CLAUDE_KEYMAP} "${CLAUDE_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Sources
source "$ZSHRC_SRC_DIR/$CLAUDE_NAMESPACE/claude_helpers.zsh"

# Constants
CLAUDE_KEYMAP_CONFIG_DIR="$HOME/.claude"
CLAUDE_KEYMAP_FILES=(CLAUDE.md settings.json)
# Note: `plans` and `skills` folders are already symlinked
CLAUDE_KEYMAP_FOLDERS=()
CLAUDE_KEYMAP_SCRATCH_DIR="$HOME/GitHub/jasonzhao6/scratch/claude/config"

function claude_keymap_c {
	check_docker

	claude
}

function claude_keymap_l {
	check_docker

	claude --resume "$*"
}

function claude_keymap_m {
	mate "$CLAUDE_KEYMAP_CONFIG_DIR"
	mate "$CLAUDE_KEYMAP_CONFIG_DIR/settings.json" "$CLAUDE_KEYMAP_CONFIG_DIR/CLAUDE.md"
}

function claude_keymap_n {
	# Run a fast haiku ping in the background to start a new 5-hour token window.

	# Suppress job control messages `[1] 12345` on launch and `[1] + done ...` on completion.
	setopt local_options no_notify no_monitor
	{
		# </dev/null: Detach stdin so background `claude` doesn't get suspended (SIGTTOU).
		# &>/dev/null: Suppress `claude` output since we only care about exit status.
		claude -p "ping" --model haiku --system-prompt "Reply to ping with pong." </dev/null &>/dev/null \
			&& green_bar "New token window" \
			|| red_bar "Failed to start token window"

		# Background output lands mid-prompt; redraw so the user gets a clean `$ ` line.
		print -Pn "${PROMPT}"
	} & disown # Background and disown so zsh forgets about this job entirely (no done message).
}

function claude_keymap_P {
	claude_helpers_move_local_to_global

	echo "Pushing Claude config to 'scratch' repository..."

	rm -rf "$CLAUDE_KEYMAP_SCRATCH_DIR"
	mkdir -p "$CLAUDE_KEYMAP_SCRATCH_DIR"

	local copy_status=0

	# Copy files; strip leading dot so dot files are visible in scratch repo
	for file in "${CLAUDE_KEYMAP_FILES[@]}"; do
		if [ -f "$CLAUDE_KEYMAP_CONFIG_DIR/$file" ]; then
			cp "$CLAUDE_KEYMAP_CONFIG_DIR/$file" "$CLAUDE_KEYMAP_SCRATCH_DIR/${file#.}" || copy_status=1
		fi
	done

	# Copy folders as-is
	for folder in "${CLAUDE_KEYMAP_FOLDERS[@]}"; do
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

function claude_keymap_PP {
	echo "Pulling Claude config from 'scratch' repository..."

	if [ -d "$CLAUDE_KEYMAP_SCRATCH_DIR" ]; then
		local copy_status=0

		# Copy files; restore leading dot for dot files
		for file in "${CLAUDE_KEYMAP_FILES[@]}"; do
			if [ -f "$CLAUDE_KEYMAP_SCRATCH_DIR/${file#.}" ]; then
				cp "$CLAUDE_KEYMAP_SCRATCH_DIR/${file#.}" "$CLAUDE_KEYMAP_CONFIG_DIR/$file" || copy_status=1
			fi
		done

		# Copy folders; remove target first so deletions in source are reflected
		for folder in "${CLAUDE_KEYMAP_FOLDERS[@]}"; do
			if [ -d "$CLAUDE_KEYMAP_SCRATCH_DIR/$folder" ]; then
				rm -rf "${CLAUDE_KEYMAP_CONFIG_DIR:?}/$folder"
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

function claude_keymap_r {
	check_docker

	claude --continue
}

function claude_keymap_s {
	# Tint the tab blue to signal scratch mode
	osascript -e '
		tell application "Terminal"
			set background color of selected tab of front window to {6224, 6224, 11224}
		end tell'

	cd "$HOME/GitHub/jasonzhao6/scratch" || exit
	# Notify Terminal.app of new cwd so Claude's tab title shows 'scratch'
	printf '\e]7;file://%s%s\a' "$HOST" "$PWD"
	claude_keymap_c

	# Restore original background color
	claude_keymap_ss
}

function claude_keymap_ss {
	osascript -e '
		tell application "Terminal"
			set background color of selected tab of front window to {6224, 6224, 6224}
		end tell'
}
