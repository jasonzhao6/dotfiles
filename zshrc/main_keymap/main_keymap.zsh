MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

MAIN_KEYMAP=()

source "$ZSHRC_DIR/$MAIN_NAMESPACE/main_helpers.zsh"

# Find and append zsh keymaps (These mappings invoke zsh functions)
while IFS= read -r line; do
	MAIN_KEYMAP+=("$line")
done < <(main_keymap_find_keymaps_by_type 'zsh')

# Find and append non-zsh keymaps (These mappings are for reference only)
MAIN_KEYMAP+=('')
while IFS= read -r line; do
	MAIN_KEYMAP+=("$line")
done < <(main_keymap_find_keymaps_by_type 'non-zsh')

# Append static entries
MAIN_KEYMAP+=(
	''
	"${MAIN_DOT}m # Show TextMate default shortcuts"
	''
	"${MAIN_DOT}r # List all keymap entries"
	"${MAIN_DOT}r <description> # Filter all keymap entries by <description>"
	''
	"${MAIN_DOT}w # List all keymap entries"
	"${MAIN_DOT}w <key> # Filter all keymap entries by <key>"
	"${MAIN_DOT}w <alias> <key> # Filter all keymap entries by <alias> and <key>"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/$MAIN_NAMESPACE/$MAIN_NAMESPACE.textmate.zsh"

function main_keymap_m {
	main_keymap_print_default_shortcuts 'TextMate' "${TEXTMATE_KEYMAP[@]}"
}

# TODO add test
function main_keymap_r {
	local description=$1

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
	local entries=()
	while IFS= read -r line; do
		line=$(eval "echo $line")

		# shellcheck disable=SC2076
		if [[ -z $alias || $line =~ "${alias}\\${KEYMAP_DOT}${key}" ]]; then
			entries+=("$line")
		fi
	done < <(pgrep "\"[$]{[A-Z]+_DOT}$key.* " "$ZSHRC_DIR"/**/*_keymap.zsh | trim_column | bw)
	# TODO add test for -

	keymap_print_entries "${entries[@]}"
}
