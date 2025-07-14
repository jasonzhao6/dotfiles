MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

MAIN_KEYMAP=(
	"${MAIN_DOT}a # List all keymap namespaces"
	"${MAIN_DOT}r # List all keymap entries"
	"${MAIN_DOT}r {description} # Filter keymap entries by description"
	"${MAIN_DOT}w {key} # Filter keymap entries by key"
	"${MAIN_DOT}- # Show stats"
	''
	# The following are default keyboard shortcuts as opposed to custom keymaps
	# Note: Keep the following in sync with `SHORTCUT_NAMESPACES`
	"${MAIN_DOT}g {regex}? # Show Gmail shortcuts"
	"${MAIN_DOT}i {regex}? # Show vi shortcuts"
	"${MAIN_DOT}l {regex}? # Show less shortcuts"
	"${MAIN_DOT}m {regex}? # Show TextMate shortcuts"
	"${MAIN_DOT}n {regex}? # Show Notion shortcuts"
	"${MAIN_DOT}o {regex}? # Show macOS shortcuts"
	"${MAIN_DOT}s {regex}? # Show Slack shortcuts"
	"${MAIN_DOT}t {regex}? # Show Terminal shortcuts"
)

# Note: Keep the following in sync with their counterparts in `MAIN_KEYMAP`
SHORTCUT_NAMESPACES=(
	''
	"${MAIN_ALIAS}g # Default keyboard shortcuts: main_keymap.gmail.zsh"
	"${MAIN_ALIAS}i # Default keyboard shortcuts: main_keymap.vi.zsh"
	"${MAIN_ALIAS}l # Default keyboard shortcuts: main_keymap.less.zsh"
	"${MAIN_ALIAS}m # Default keyboard shortcuts: main_keymap.textmate.zsh"
	"${MAIN_ALIAS}n # Default keyboard shortcuts: main_keymap.notion.zsh"
	"${MAIN_ALIAS}o # Default keyboard shortcuts: main_keymap.macos.zsh"
	"${MAIN_ALIAS}s # Default keyboard shortcuts: main_keymap.slack.zsh"
	"${MAIN_ALIAS}t # Default keyboard shortcuts: main_keymap.terminal.zsh"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_show $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.zsh"
source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.quarantine.zsh"

function main_keymap_- {
	main_keymap_find_key_mappings

	echo
	echo Code stats:

	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings`
	echo "- ${#reply_zsh_mappings} zsh mappings"

	# shellcheck disable=SC2154 # Assigned by `main_keymap_find_key_mappings`
	echo "- ${#reply_non_zsh_mappings} non-zsh mappings"

	ZSHRC_LINES_OF_CODE=$(main_keymap_count_lines_of_code)
	echo "- $ZSHRC_LINES_OF_CODE lines of code"

	ZSHRC_LINE_COUNT=$(main_keymap_count_lines)
	echo "- $ZSHRC_LINE_COUNT lines total"
}

ALL_NAMESPACE="$MAIN_NAMESPACE.all_namespaces"
ALL_KEYMAP_FILE="$ZSHRC_DIR/$MAIN_NAMESPACE/$ALL_NAMESPACE.zsh"

source "$ALL_KEYMAP_FILE"

# Includes custom zsh and non-zsh keymaps
# But excludes default keyboard shortcuts
function main_keymap_a {
	# Show the cached keymap-of-keymaps right away; append the shortcut namespaces for completeness
	keymap_print_help "$ALL_NAMESPACE" '(no-op)' "${ALL_KEYMAP[@]}" "${SHORTCUT_NAMESPACES[@]}"

	# Generate a new keymap-of-keymaps; if different, show a red notice
	cp "$ALL_KEYMAP_FILE" "$ALL_KEYMAP_FILE.bak"
	main_keymap_extract_keymaps 'ALL_KEYMAP'
	if ! cmp --silent "$ALL_KEYMAP_FILE" "$ALL_KEYMAP_FILE.bak"; then
		source "$ALL_KEYMAP_FILE"
		echo
		red_bar "\`$ALL_NAMESPACE\` updated"
	fi
	rm "$ALL_KEYMAP_FILE.bak"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.gmail.zsh"
function main_keymap_g {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'gmail' "$description"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.vi.zsh"
function main_keymap_i {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'vi' "$description"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.less.zsh"
function main_keymap_l {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'less' "$description"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.textmate.zsh"
function main_keymap_m {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'textmate' "$description"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.notion.zsh"
function main_keymap_n {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'notion' "$description"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.macos.zsh"
function main_keymap_o {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'macos' "$description"
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
	main_keymap_show_default_keyboard_shortcuts 'slack' "$description"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.terminal.zsh"
function main_keymap_t {
	local description=$*
	main_keymap_show_default_keyboard_shortcuts 'terminal' "$description"
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
