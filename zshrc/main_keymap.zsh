MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

MAIN_KEYMAP=()

# Find zsh keymaps (These mappings invoke zsh functions)
source "$ZSHRC_DIR/main_helpers.zsh"
while IFS='' read -r line; do MAIN_KEYMAP+=("$line"); done < <(main_keymap_find_all)

# Append non-zsh keymaps (These mappings are for reference only)
MAIN_KEYMAP+=( # TODO create these keymaps
	''
#	"${MAIN_DOT}s # Show system default keymap"
#	''
#	"${MAIN_DOT}i # Show IntelliJ \`cmd\` keymap"
#	"${MAIN_DOT}ic # Show IntelliJ \`ctrl\` keymap"
#	"${MAIN_DOT}ia # Show IntelliJ \`alt\` keymap"
#	"${MAIN_DOT}if # Show IntelliJ \`fn\` keymap"
#	''
	"${MAIN_DOT}m # Show TextMate keymap"
#	"${MAIN_DOT}n # Show Notion keymap"
#	"${MAIN_DOT}t # Show Terminal keymap"
	"${MAIN_DOT}vv # Show Vimium / Vimari keymap"
	"${MAIN_DOT}vs # Show Vimium search keymap"
#	''
#	"${MAIN_DOT}ki # Show Kinesis keymap"
)

# Append mappings for this keymaps
MAIN_KEYMAP+=(
	''
	"${MAIN_DOT}k # List keymap entries"
	"${MAIN_DOT}k <key> # Filter across namespaces"
	"${MAIN_DOT}k <namespace> <key> # Filter a specific namespace"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Source non-zsh keymaps and validate them
#



#
# Key mappings (Alphabetized)
#

function main_keymap_k {
	local namespace
	local key

	if [[ -z $2 ]]; then
		key=$1
	else
		namespace=$1
		key=$2
	fi

	local formatted_line
	pgrep "[$]{[A-Z]+_DOT}$key\w*" "$ZSHRC_DIR"/*_keymap.zsh |
		trim_column |
		bw | # In order for `keymap_print_entry` to align comments
		while IFS= read -r line; do

		formatted_line=$(keymap_print_entry "$(eval "echo $line")" 40)

		# shellcheck disable=SC2076
		if [[ -z $namespace || $formatted_line =~ " $namespace\.$key" ]]; then
			echo "$formatted_line"
		fi
	done
}

source "$ZSHRC_DIR/main_keymap.textmate.zsh"

function main_keymap_m {
	main_keymap_print_keyboard_shortcuts 'TextMate' "${TEXTMATE_KEYMAP[@]}"
}

function main_keymap_vs {
	cat "$DOTFILES_DIR"/vimium/vimium-searches.txt
}

function main_keymap_vv {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
