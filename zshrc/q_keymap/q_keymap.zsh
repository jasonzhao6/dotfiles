Q_NAMESPACE='q_keymap'
Q_ALIAS='q'
Q_DOT="${Q_ALIAS}${KEYMAP_DOT}"

Q_KEYMAP=(
	"${Q_DOT}q # Chat without MCP"
	"${Q_DOT}a # Chat with Atlassian MCP"
	"${Q_DOT}d # Chat with Datadog MCP"
	"${Q_DOT}h # Chat with GitHub MCP"
	"${Q_DOT}s # Chat with SDLC MCP"
	"${Q_DOT}t # Chat with Trancache context"
	''
	"${Q_DOT}c # Vibe code in the current repo"
	"${Q_DOT}j # Vibe code in the JCard repo"
	"${Q_DOT}k # Vibe code in the K8s Helm repo"
	''
	"${Q_DOT}0 <command>? # Invoke \`q\`"
	"${Q_DOT}4 <command>? # Invoke \`q chat\` with \`claude-opus-4.5\`"
	''
	"${Q_DOT}o # Open \`kiro\` folder in Finder"
	"${Q_DOT}m # Edit \`kiro\` folder in TextMate"
	"${Q_DOT}p # Push \`kiro\` folder to \`scratch\` repo"
	"${Q_DOT}P # Pull \`kiro\` folder from \`scratch\` repo"
)

keymap_init $Q_NAMESPACE $Q_ALIAS "${Q_KEYMAP[@]}"

function q_keymap {
	keymap_show $Q_NAMESPACE $Q_ALIAS ${#Q_KEYMAP} "${Q_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

Q_KEYMAP_JCARD_DIR="$HOME/GitHub/transaction-engine/marqeta-jpos/jcard"
Q_KEYMAP_HELM_DIR="$HOME/GitHub/transaction-engine/ccapi-marqkubed-helm"
Q_KEYMAP_SOURCE_DIR="$HOME/GitHub/jasonzhao6/scratch/kiro"
Q_KEYMAP_SUB_DIRS=(agents my-agent-configs my-agent-contexts my-global-contexts)
Q_KEYMAP_TARGET_DIR="$HOME/.kiro"

function q_keymap_0 {
	# Check if Docker is running; Q's MCP servers run on it
	docker info 2> /dev/null |
		grep 'Server Version' > /dev/null &&
		green_bar 'Docker is running' ||
		red_bar 'Docker is NOT running'

	~/.local/bin/kiro-cli "$@"
}

function q_keymap_4 {
	q_keymap_0 chat --model claude-opus-4.5 "$@"
}

function q_keymap_a {
	q_keymap_4 --agent atlassian
}

function q_keymap_c {
	q_keymap_4 --agent code
}

function q_keymap_d {
	q_keymap_4 --agent datadog
}

function q_keymap_h {
	q_keymap_4 --agent github
}

function q_keymap_j {
	cd "$Q_KEYMAP_JCARD_DIR" || return
	q_keymap_4 --agent code
}

function q_keymap_k {
	cd "$Q_KEYMAP_HELM_DIR" || return
	q_keymap_4 --agent code
}

function q_keymap_m {
	mate "$Q_KEYMAP_TARGET_DIR"
}

function q_keymap_o {
	open "$Q_KEYMAP_TARGET_DIR"
}

function q_keymap_p {
	echo "Pushing 'kiro' folder to 'scratch' repository..."

	rm -rf "$Q_KEYMAP_SOURCE_DIR"
	mkdir -p "$Q_KEYMAP_SOURCE_DIR"

	local copy_status=0
	for subfolder in $Q_KEYMAP_SUB_DIRS; do
		if [ -d "$Q_KEYMAP_TARGET_DIR/$subfolder" ]; then
			cp -r "$Q_KEYMAP_TARGET_DIR/$subfolder" "$Q_KEYMAP_SOURCE_DIR/" || copy_status=1
		fi
	done

	if [ $copy_status -eq 0 ]; then
		echo "Push operation completed."
	else
		echo "Error: Failed to copy 'kiro' folder."
	fi
}

function q_keymap_P {
	echo "Pulling 'kiro' folder from 'scratch' repository..."

	if [ -d "$Q_KEYMAP_SOURCE_DIR" ]; then
		local copy_status=0
		for subfolder in $Q_KEYMAP_SUB_DIRS; do
			if [ -d "$Q_KEYMAP_SOURCE_DIR/$subfolder" ]; then
				rm -rf "$Q_KEYMAP_TARGET_DIR/$subfolder"
				cp -r "$Q_KEYMAP_SOURCE_DIR/$subfolder" "$Q_KEYMAP_TARGET_DIR/" || copy_status=1
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

function q_keymap_q {
	q_keymap_4 --agent q
}

function q_keymap_s {
	q_keymap_4 --agent sdlc
}

function q_keymap_t {
	cd "$Q_KEYMAP_JCARD_DIR" || return
	q_keymap_4 --agent trancache
}
