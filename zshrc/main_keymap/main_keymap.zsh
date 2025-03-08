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
	keymap_show $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.zsh"

# shellcheck disable=SC1064,SC1072,SC1073 # Allow `,` in function name
function main_keymap_, {
	main_keymap_find_key_mappings

	echo
	echo Code stats:

	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings`
	echo "- ${#reply_zsh_mappings} zsh mappings"

	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings`
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
function main_keymap_g {
	local description=$*
	main_keymap_show_non_zsh_keymap 'Gmail' $description
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.textmate.zsh"
function main_keymap_m {
	local description=$*
	main_keymap_show_non_zsh_keymap 'TextMate' $description
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.notion.zsh"
function main_keymap_n {
	local description=$*
	main_keymap_show_non_zsh_keymap 'Notion' $description
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

	main_keymap_find_key_mappings "$description"

	local is_zsh_keymap=1
	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings`
	main_keymap_print_key_mappings $is_zsh_keymap "${reply_zsh_mappings[@]}"

	is_zsh_keymap=0
	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings`
	main_keymap_print_key_mappings $is_zsh_keymap "${reply_non_zsh_mappings[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.slack.zsh"
function main_keymap_s {
	local description=$*
	main_keymap_show_non_zsh_keymap 'Slack' $description
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.terminal.zsh"
function main_keymap_t {
	local description=$*
	main_keymap_show_non_zsh_keymap 'Terminal' $description
}

# Includes zsh keymaps following a `KEYMAP_DOT`, e.g `g.x`
# Includes non-zsh keymaps following a `KEYMAP_DASH`, e.g `alt-x`
function main_keymap_w {
	local key=$1
	[[ -z $key ]] && echo && red_bar 'key required' && return

	# Find zsh entries with matching `key`
	local keymap_entries=()
	local is_zsh_keymap=1
	while IFS= read -r entry; do
		entry=$(eval "echo $entry")
		keymap_entries+=("$entry")
	done < <(egrep "^\t\"[$]{[A-Z]+_DOT}$key" "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)
	main_keymap_print_key_mappings $is_zsh_keymap "${keymap_entries[@]}"

	# Find non-zsh keymap entries with matching `key`
	keymap_entries=()
	is_zsh_keymap=0
	while IFS= read -r entry; do
		entry=$(eval "echo $entry")
		keymap_entries+=("$entry")
	done < <(egrep "^\t\".*$KEYMAP_DASH$key " "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)
	main_keymap_print_key_mappings $is_zsh_keymap "${keymap_entries[@]}"
}
