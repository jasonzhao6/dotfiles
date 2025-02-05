MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

MAIN_KEYMAP=(
	"${MAIN_DOT}a # List all keymap namespaces"
	''
	"${MAIN_DOT}r # List all keymap entries"
	"${MAIN_DOT}r {description} # Filter by description"
	"${MAIN_DOT}w {key} # Filter by key"
	''
	# These are default keyboard shortcuts as opposed to custom keymaps
	"${MAIN_DOT}g # Show Gmail shortcuts"
	"${MAIN_DOT}m # Show TextMate shortcuts"
	"${MAIN_DOT}n # Show Notion shortcuts"
	"${MAIN_DOT}o # Show macOS shortcuts"
	"${MAIN_DOT}s # Show Slack shortcuts"
	"${MAIN_DOT}t # Show Terminal shortcuts"
	''
	"${MAIN_DOT}, # Show stats"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.zsh"

# shellcheck disable=SC1064,SC1072,SC1073 # Allow `,` in function name
function main_keymap_, {
	main_keymap_find_key_mappings_by_type

	echo
	echo Code stats:

	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings_by_type`
	echo "- ${#reply_zsh_mappings} zsh mappings"

	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings_by_type`
	echo "- ${#reply_non_zsh_mappings} non-zsh mappings"

	ZSHRC_LINE_OF_CODE=$(egrep --invert-match '^\s*(#|$)' "$ZSHRC_DIR"/**/*.zsh | wc -l | strip_left)
	echo "- $ZSHRC_LINE_OF_CODE lines of code"

	ZSHRC_LINE_COUNT=$(cat "$ZSHRC_DIR"/**/*.zsh | wc -l | strip_left)
	echo "- $ZSHRC_LINE_COUNT lines total"
}

ALL_NAMESPACE='Keymap of keymaps'
ALL_KEYMAP_FILE="$ZSHRC_DIR/${MAIN_NAMESPACE}/$MAIN_NAMESPACE.all.zsh"

source "$ALL_KEYMAP_FILE"
keymap_set_alias "${MAIN_ALIAS}a-" "main_keymap_a > /dev/null && keymap_filter_entries ALL_KEYMAP"

# Includes custom zsh and non-zsh keymaps
# But excludes default keyboard shortcuts
function main_keymap_a {
	# Show the cached keymap-of-keymaps right away
	keymap_print_help "$ALL_NAMESPACE" '(no-op)' "${ALL_KEYMAP[@]}"

	# Generate a new keymap-of-keymaps; if different, show a red notice
	cp "$ALL_KEYMAP_FILE" "$ALL_KEYMAP_FILE.bak"
	main_keymap_extract_keymaps 'ALL_KEYMAP'
	if cmp --silent "$ALL_KEYMAP_FILE" "$ALL_KEYMAP_FILE.bak"; then
		rm "$ALL_KEYMAP_FILE.bak"
	else
		source "$ALL_KEYMAP_FILE"
		echo
		red_bar 'Keymap of keymaps updated'
	fi
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.gmail.zsh"
keymap_set_alias "${MAIN_ALIAS}g-" "keymap_filter_entries GMAIL_KEYMAP"
function main_keymap_g {
	# shellcheck disable=SC2153 # Assigned in `main_keymap.gmail.zsh`
	main_keymap_print_keyboard_shortcuts 'Gmail' "${GMAIL_KEYMAP[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.textmate.zsh"
keymap_set_alias "${MAIN_ALIAS}m-" "keymap_filter_entries TEXTMATE_KEYMAP"
function main_keymap_m {
	main_keymap_print_keyboard_shortcuts 'TextMate' "${TEXTMATE_KEYMAP[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.notion.zsh"
keymap_set_alias "${MAIN_ALIAS}n-" "keymap_filter_entries NOTION_KEYMAP"
function main_keymap_n {
	main_keymap_print_keyboard_shortcuts 'Notion' "${NOTION_KEYMAP[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.mac_os.zsh"
keymap_set_alias "${MAIN_ALIAS}o-" "keymap_filter_entries MAC_OS_KEYMAP"
function main_keymap_o {
	main_keymap_print_keyboard_shortcuts 'macOS' "${MAC_OS_KEYMAP[@]}"
}

# Includes custom zsh and non-zsh keymaps
# Also includes default keyboard shortcuts
function main_keymap_r {
	local description=$*

	main_keymap_find_key_mappings_by_type "$description"

	local is_zsh_keymap=1
	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings_by_type`
	main_keymap_print_key_mappings $is_zsh_keymap "${reply_zsh_mappings[@]}"

	is_zsh_keymap=0
	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings_by_type`
	main_keymap_print_key_mappings $is_zsh_keymap "${reply_non_zsh_mappings[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.slack.zsh"
keymap_set_alias "${MAIN_ALIAS}s-" "keymap_filter_entries SLACK_KEYMAP"
function main_keymap_s {
	main_keymap_print_keyboard_shortcuts 'Slack' "${SLACK_KEYMAP[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.terminal.zsh"
keymap_set_alias "${MAIN_ALIAS}t-" "keymap_filter_entries TERMINAL_KEYMAP"
function main_keymap_t {
	main_keymap_print_keyboard_shortcuts 'Terminal' "${TERMINAL_KEYMAP[@]}"
}

# Includes zsh keymaps following a `KEYMAP_DOT`
# Includes non-zsh keymaps following a `KEYMAP_DASH`
function main_keymap_w {
	local key=$1
	[[ -z $key ]] && echo && red_bar 'key required' && return

	# Find zsh entries with matching `key`
	local entries=()
	local is_zsh_keymap=1
	while IFS= read -r entry; do
		entry=$(eval "echo $entry")
		entries+=("$entry")
	done < <(egrep "^\t\"[$]{[A-Z]+_DOT}$key" "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)
	main_keymap_print_key_mappings $is_zsh_keymap "${entries[@]}"

	# Find non-zsh entries with matching `key`
	entries=()
	is_zsh_keymap=0
	while IFS= read -r entry; do
		entry=$(eval "echo $entry")
		entries+=("$entry")
	done < <(egrep "^\t\".*$KEYMAP_DASH$key " "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)
	main_keymap_print_key_mappings $is_zsh_keymap "${entries[@]}"
}
