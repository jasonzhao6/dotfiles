MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

MAIN_KEYMAP=(
	"${MAIN_DOT}a # List all keymaps"
	''
	"${MAIN_DOT}r # List zsh keymap entries"
	"${MAIN_DOT}r [description] # Filter zsh keymap entries by description"
	''
	"${MAIN_DOT}w # List zsh keymap entries"
	"${MAIN_DOT}w [key] # Filter zsh keymap entries by key"
	"${MAIN_DOT}w [alias] [key] # Filter zsh keymap entries by alias and key"
	''
	"${MAIN_DOT}g # Show Gmail keyboard shortcuts"
	"${MAIN_DOT}m # Show TextMate keyboard shortcuts"
	"${MAIN_DOT}n # Show Notion keyboard shortcuts"
	"${MAIN_DOT}o # Show macOS keyboard shortcuts"
	"${MAIN_DOT}s # Show Slack keyboard shortcuts"
	"${MAIN_DOT}t # Show Terminal keyboard shortcuts"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.zsh"

MAIN_KEYMAP_ALL=()

function main_keymap_a {
	# Generate once
	if [[ -z $MAIN_KEYMAP_ALL ]]; then
		# Find and append zsh keymaps (These mappings invoke zsh functions)
		while IFS= read -r line; do
			MAIN_KEYMAP_ALL+=("$line")
		done < <(main_keymap_find_keymaps_by_type 'zsh')

		# Find and append non-zsh keymaps (These mappings are used outside of zsh)
		MAIN_KEYMAP_ALL+=('')
		while IFS= read -r line; do
			MAIN_KEYMAP_ALL+=("$line")
		done < <(main_keymap_find_keymaps_by_type 'non-zsh')
	fi

	main_keymap_print_keyboard_shortcuts 'Keymaps' "${MAIN_KEYMAP_ALL[@]}"
}

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.gmail.zsh"
keymap_set_alias "${MAIN_ALIAS}g-" "keymap_filter_entries GMAIL_KEYMAP"
function main_keymap_g {
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

function main_keymap_r {
	local description=$*

	# Find all matching keymap entries
	local entries=()
	while IFS= read -r line; do
		entries+=("$(eval "echo $line")")
	done < <(
		pgrep -i "[$]{[A-Z]+_DOT}.* # .*$description" "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw
	)
	# Note: ^ Spelling out `--ignore-case` here somehow breaks IntelliJ IDEA's syntax highlighting

	keymap_print_entries "${entries[@]}"
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

function main_keymap_w {
	local alias
	local key

	# Handle `[key]` arg
	if [[ -z $2 ]]; then
		key=$1

	# Handle `[alias] [key]` args
	else
		alias=$1
		key=$2
	fi

	# Find all matching keymap entries
	local entries=()
	while IFS= read -r line; do
		line=$(eval "echo $line")

		# shellcheck disable=SC2076
		if [[ -z $alias || $line =~ "${alias}\\${KEYMAP_DOT}${key}" ]]; then
			entries+=("$line")
		fi
	done < <(
		pgrep "\"[$]{[A-Z]+_DOT}$key.* " "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw
	)

	keymap_print_entries "${entries[@]}"
}
