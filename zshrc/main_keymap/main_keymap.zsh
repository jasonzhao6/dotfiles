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
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.zsh"

ALL_NAMESPACE='All Keymaps'
ALL_KEYMAP=()
keymap_set_alias "${MAIN_ALIAS}a-" \
	"main_keymap_a > /dev/null && keymap_filter_entries ALL_KEYMAP"
function main_keymap_a {
	# Generate once
	if [[ -z ${ALL_KEYMAP[*]} ]]; then
		# Find and append zsh keymaps (These mappings invoke zsh functions)
		while IFS= read -r line; do
			ALL_KEYMAP+=("$line")
		done < <(main_keymap_find_keymaps_by_type 'zsh')

		# Find and append non-zsh keymaps (These mappings are used outside of zsh)
		ALL_KEYMAP+=('')
		while IFS= read -r line; do
			ALL_KEYMAP+=("$line")
		done < <(main_keymap_find_keymaps_by_type 'non-zsh')
	fi

	keymap_print_help "$ALL_NAMESPACE" '(no-op)' "${ALL_KEYMAP[@]}"
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

function main_keymap_r {
	local description=$*

	local keymaps; keymaps=$(keymap_names)

	# Declare vars used in `while` loop
	local all_zsh_entries=()
	local all_non_zsh_entries=()
	local current_entries
	local non_zsh_namespace

	# shellcheck disable=SC2034 # Used to define `current_entries`
	while IFS= read -r keymap; do
		# shellcheck disable=SC2206 # Adding double quote breaks array expansion
		current_entries=(${(P)keymap})
		# Note: ^ `current_entries=("${(P)$(echo "$keymap")[@]}")` actually works
		# But it's convoluted, and it leaves in the empty entries, which we do not want

		# Find keymap entries with matching description
		setopt nocasematch
		if keymap_has_dot_alias "${current_entries[@]}"; then
			for entry in "${current_entries[@]}"; do
				# shellcheck disable=SC2076
				if [[ -z $description || $entry =~ ".* # .*$description.*" ]]; then
					all_zsh_entries+=("$entry")
				fi
			done
		else
			# Unlike zsh entries, non-zsh entries lack a leading alias to indicate namespace
			non_zsh_namespace=$(echo "${keymap%_KEYMAP}" | downcase)

			for entry in "${current_entries[@]}"; do
				# shellcheck disable=SC2076
				if [[ -z $description || $entry =~ ".* # .*$description.*" ]]; then
					all_non_zsh_entries+=("$non_zsh_namespace: $entry")
				fi
			done
		fi
		unsetopt nocasematch
	done <<< "$keymaps"

	# Print entries
	local is_zsh_keymap=1
	keymap_print_entries $is_zsh_keymap "${all_zsh_entries[@]}"
	is_zsh_keymap=0
	keymap_print_entries $is_zsh_keymap "${all_non_zsh_entries[@]}"
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
	local key=$1
	[[ -z $key ]] && echo && red_bar 'key required' && return

	# Find zsh entries with matching `key`
	local zsh_entries=()
	while IFS= read -r entry; do
		entry=$(eval "echo $entry")

		# shellcheck disable=SC2076
		# Intentionally not adding a trailing space to match multi-char keys
		if [[ $entry =~ "\\${KEYMAP_DOT}${key}" ]]; then
			zsh_entries+=("$entry")
		fi
	done < <(egrep "^\t\"[$]{[A-Z]+_DOT}$key" "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)

	# Find non-zsh entries with matching `key`
	local non_zsh_entries=()
	while IFS= read -r entry; do
		entry=$(eval "echo $entry")

		# shellcheck disable=SC2076
		# Intentionally adding a trailing space to ensure it's the last stroke of a keyboard shortcut
		if [[ $entry =~ "\\${KEYMAP_DASH}${key} " ]]; then
			non_zsh_entries+=("$entry")
		fi
	done < <(egrep "^\t\".*$KEYMAP_DASH$key " "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)

	# Print entries
	local is_zsh_keymap=1
	keymap_print_entries $is_zsh_keymap "${zsh_entries[@]}"
	is_zsh_keymap=0
	keymap_print_entries $is_zsh_keymap "${non_zsh_entries[@]}"
}
