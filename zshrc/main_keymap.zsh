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
	main_keymap_print_keyboard_shortcuts 'TextMate' "${TEXTMATE_KEYMAP[@]}"
}

function main_keymap_vs {
	cat "$DOTFILES_DIR"/vimium/vimium-searches.txt
}

function main_keymap_vv {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}

function main_keymap_w {
	local alias
	local key

	if [[ -z $2 ]]; then
		key=$1
	else
		alias=$1
		key=$2
	fi

	local lines=()
	while IFS= read -r line; do
		line=$(eval "echo $line")

		# shellcheck disable=SC2076
		if [[ -z $alias || $line =~ "${alias}\\${KEYMAP_DOT}${key}" ]]; then
			lines+=("$line")
		fi
	done <<< "$(pgrep "[$]{[A-Z]+_DOT}$key\w* " "$ZSHRC_DIR"/*_keymap.zsh | trim_column | bw)"

	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${lines[@]}")

	for entry in "${lines[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}
