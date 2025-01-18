MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

MAIN_KEYMAP=()

source "$ZSHRC_DIR/main_helpers.zsh"

# Find and append zsh keymaps (These mappings invoke zsh functions)
while IFS='' read -r line; do
	MAIN_KEYMAP+=("$line")
done < <(main_keymap_find_keymaps_by_type 'zsh')

# Find and append non-zsh keymaps (These mappings are for reference only)
MAIN_KEYMAP+=('')
while IFS='' read -r line; do
	MAIN_KEYMAP+=("$line")
done < <(main_keymap_find_keymaps_by_type 'non-zsh')

# Append static entries
MAIN_KEYMAP+=(
	''
	"${MAIN_DOT}m # Show TextMate default shortcuts"
	''
	"${MAIN_DOT}w # List keymap entries"
	"${MAIN_DOT}w <key> # Filter keymap entries"
	"${MAIN_DOT}w <alias> <key> # Filter keymap entries given an alias"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/main_keymap.textmate.zsh"

function main_keymap_m {
	main_keymap_print_default_shortcuts 'TextMate' "${TEXTMATE_KEYMAP[@]}"
}

function main_keymap_w {
	local alias
	local key

	# Handle `<key>` arg
	if [[ -z $2 ]]; then
		key=$1

	# Handle `<alias> <key>` args
	else
		alias=$1
		key=$2
	fi

	# Find all matching keymap entries
	local lines=()
	while IFS= read -r line; do
		line=$(eval "echo $line")

		# shellcheck disable=SC2076
		if [[ -z $alias || $line =~ "${alias}\\${KEYMAP_DOT}${key}" ]]; then
			lines+=("$line")
		fi
	done <<< "$(pgrep "[$]{[A-Z]+_DOT}$key\w* " "$ZSHRC_DIR"/*_keymap.zsh | trim_column | bw)"

	# Pretty print keymap entries
	local max_command_size; max_command_size=$(keymap_get_max_command_size "${lines[@]}")
	for entry in "${lines[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}
