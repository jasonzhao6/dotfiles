Q_NAMESPACE='q_keymap'
Q_ALIAS='q'
Q_DOT="${Q_ALIAS}${KEYMAP_DOT}"

Q_KEYMAP=(
	"${Q_DOT}q # Invoke \`q chat\` without any MCP"
	"${Q_DOT}h # Invoke \`q chat\` with GitHub MCP"
	"${Q_DOT}j # Invoke \`q chat\` with Jira MCP"
	''
	"${Q_DOT}0 # Invoke the plain \`q\` command"
	"${Q_DOT}4 # Invoke \`q chat\` with \`claude-4-sonnet\`"
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
	~/.local/bin/q
}

function q_keymap_4 {
	q_keymap_0 chat --model claude-4-sonnet
}

function q_keymap_h {
	cp "$Q_KEYMAP_DIR"/profiles/github/mcp.json "$Q_KEYMAP_DIR"/; q_keymap_0 --profile github
}

function q_keymap_j {
	cp "$Q_KEYMAP_DIR"/profiles/jira/mcp.json "$Q_KEYMAP_DIR"/; q_keymap_0 --profile jira
}

function q_keymap_q {
	rm -f "$Q_KEYMAP_DIR"/mcp.json; q_keymap_4
}
