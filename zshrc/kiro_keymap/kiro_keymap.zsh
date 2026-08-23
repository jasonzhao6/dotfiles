KIRO_NAMESPACE='kiro_keymap'
KIRO_ALIAS='r'
KIRO_DOT="${KIRO_ALIAS}${KEYMAP_DOT}"

KIRO_KEYMAP=(
	"${KIRO_DOT}c # Code in current repo"
	"${KIRO_DOT}r # Resume last session"
	"${KIRO_DOT}l # List prior sessions"
	''
	"${KIRO_DOT}a # Chat with Atlassian MCP"
	"${KIRO_DOT}d # Chat with Datadog MCP"
	"${KIRO_DOT}e # Chat with Snowflake MCP"
	"${KIRO_DOT}h # Chat with GitHub MCP"
	"${KIRO_DOT}s # Chat with SDLC MCP"
	"${KIRO_DOT}t # Chat with Trancache context"
	''
	"${KIRO_DOT}w # Edit config in TextMate (\`rm\` reserved)"
	"${KIRO_DOT}p # Push \`kiro\` folder to \`scratch\` repo"
	"${KIRO_DOT}P # Pull \`kiro\` folder from \`scratch\` repo"
	''
	"${KIRO_DOT}0 <command>? # Invoke \`kiro-cli\` plain"
	"${KIRO_DOT}o <command>? # Invoke \`kiro-cli\` with best model"
	''
	"${KIRO_DOT}m # (Reserved: Remove files)"
)

keymap_init $KIRO_NAMESPACE $KIRO_ALIAS "${KIRO_KEYMAP[@]}"

function kiro_keymap {
	keymap_show $KIRO_NAMESPACE $KIRO_ALIAS ${#KIRO_KEYMAP} "${KIRO_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

# Constants
KIRO_KEYMAP_SCRATCH_DIR="$HOME/GitHub/jasonzhao6/scratch/kiro"
KIRO_KEYMAP_SUB_DIRS=(agents my-agent-configs my-agent-contexts my-global-contexts)
KIRO_KEYMAP_CONFIG_DIR="$HOME/.kiro"

function kiro_keymap_0 {
	# Check if Docker is running; Kiro's MCP servers run on it
	docker info 2> /dev/null |
		grep 'Server Version' > /dev/null &&
		green_bar 'Docker is running' ||
		red_bar 'Docker is not running'

	~/.local/bin/kiro-cli "$@"
}

function kiro_keymap_a {
	kiro_keymap_o --agent atlassian
}

function kiro_keymap_c {
	kiro_keymap_o --agent code
}

function kiro_keymap_d {
	kiro_keymap_o --agent datadog
}

function kiro_keymap_e {
	kiro_keymap_o --agent snowflake
}

function kiro_keymap_h {
	kiro_keymap_o --agent github
}

function kiro_keymap_l {
	kiro_keymap_0 --list
}

function kiro_keymap_o {
	# Default to q agent if no --agent specified
	if [[ ! " $* " =~ " --agent " ]]; then
		kiro_keymap_0 chat --model claude-opus-4.5 --agent q "$@"
	else
		kiro_keymap_0 chat --model claude-opus-4.5 "$@"
	fi
}

function kiro_keymap_p {
	echo "Pushing 'kiro' folder to 'scratch' repository..."

	rm -rf "$KIRO_KEYMAP_SCRATCH_DIR"
	mkdir -p "$KIRO_KEYMAP_SCRATCH_DIR"

	local copy_status=0
	for subfolder in "${KIRO_KEYMAP_SUB_DIRS[@]}"; do
		if [ -d "$KIRO_KEYMAP_CONFIG_DIR/$subfolder" ]; then
			cp -r "$KIRO_KEYMAP_CONFIG_DIR/$subfolder" "$KIRO_KEYMAP_SCRATCH_DIR/" || copy_status=1
		fi
	done

	if [ $copy_status -eq 0 ]; then
		echo "Push operation completed."
	else
		echo "Error: Failed to copy 'kiro' folder."
	fi
}

function kiro_keymap_P {
	echo "Pulling 'kiro' folder from 'scratch' repository..."

	if [ -d "$KIRO_KEYMAP_SCRATCH_DIR" ]; then
		local copy_status=0
		for subfolder in "${KIRO_KEYMAP_SUB_DIRS[@]}"; do
			if [ -d "$KIRO_KEYMAP_SCRATCH_DIR/$subfolder" ]; then
				rm -rf "${KIRO_KEYMAP_CONFIG_DIR:?}/$subfolder"
				cp -r "$KIRO_KEYMAP_SCRATCH_DIR/$subfolder" "$KIRO_KEYMAP_CONFIG_DIR/" || copy_status=1
			fi
		done

		if [ $copy_status -eq 0 ]; then
			echo "Pull operation completed successfully."
		else
			echo "Error: Failed to copy 'kiro' folder from 'scratch' repository."
		fi
	else
		echo "Error: 'kiro' folder not found in 'scratch' repository."
	fi
}

function kiro_keymap_r {
	kiro_keymap_0 --resume
}

function kiro_keymap_s {
	kiro_keymap_o --agent sdlc
}

function kiro_keymap_t {
	cd "$KIRO_KEYMAP_JCARD_DIR" || return
	kiro_keymap_o --agent trancache
}

function kiro_keymap_w {
	mate "$KIRO_KEYMAP_CONFIG_DIR"
}
