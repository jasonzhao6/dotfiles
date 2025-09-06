Q_NAMESPACE='q_keymap'
Q_ALIAS='q'
Q_DOT="${Q_ALIAS}${KEYMAP_DOT}"

Q_KEYMAP=(
	"${Q_DOT}q # Chat without MCP"
	"${Q_DOT}a # Chat with Atlassian MCP"
	"${Q_DOT}h # Chat with GitHub MCP"
	''
	"${Q_DOT}0 <command>? # Invoke \`q\`"
	"${Q_DOT}4 <command>? # Invoke \`q chat\` with \`claude-4-sonnet\`"
	''
	"${Q_DOT}o # Open \`amazonq\` folder in Finder"
	"${Q_DOT}m # Edit \`amazonq\` folder in TextMate"
	"${Q_DOT}p # Push \`amazonq\` folder to \`scratch\` repo"
	"${Q_DOT}P # Pull \`amazonq\` folder from \`scratch\` repo"
)

keymap_init $Q_NAMESPACE $Q_ALIAS "${Q_KEYMAP[@]}"

function q_keymap {
	keymap_show $Q_NAMESPACE $Q_ALIAS ${#Q_KEYMAP} "${Q_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

Q_KEYMAP_DIR="$HOME/.aws/amazonq"

function q_keymap_0 {
	# Check if Docker is running; Q's MCP servers run on it
	docker info 2> /dev/null |
		grep 'Server Version' > /dev/null &&
		green_bar 'Docker is running' ||
		red_bar 'Docker is NOT running'

	~/.local/bin/q "$@"
}

function q_keymap_4 {
	q_keymap_0 chat --model claude-4-sonnet "$@"
}

function q_keymap_a {
	q_keymap_4 --agent atlassian
}

function q_keymap_h {
	q_keymap_4 --agent github
}

function q_keymap_m {
	mate "$Q_KEYMAP_DIR"
}

function q_keymap_o {
	open "$Q_KEYMAP_DIR"
}

function q_keymap_p {
	echo "Pushing 'amazonq' folder to 'scratch' repository..."

	if [ -d "$HOME/GitHub/jasonzhao6/scratch/amazonq" ]; then
		rm -rf "$HOME/GitHub/jasonzhao6/scratch/amazonq"
		cp -r "$HOME/.aws/amazonq" "$HOME/GitHub/jasonzhao6/scratch/"

		if [ $? -eq 0 ]; then
			echo "Push operation completed."
		else
			echo "Error: Failed to copy 'amazonq' folder."
		fi
	else
		echo "Error: 'amazonq' folder not found in 'scratch' repository."
	fi
}

function q_keymap_P {
	echo "Pulling 'amazonq' folder from 'scratch' repository..."

	if [ -d "$HOME/GitHub/jasonzhao6/scratch/amazonq" ]; then
		rm -rf "$HOME/.aws/amazonq"
		cp -r "$HOME/GitHub/jasonzhao6/scratch/amazonq" "$HOME/.aws/"

		if [ $? -eq 0 ]; then
			echo "Pull operation completed successfully."
		else
			echo "Error: Failed to copy 'amazonq' folder from 'scratch' repository."
		fi
	else
		echo "Error: 'amazonq' folder not found in 'scratch' repository."
	fi
}

function q_keymap_q {
	q_keymap_4 --agent q
}
