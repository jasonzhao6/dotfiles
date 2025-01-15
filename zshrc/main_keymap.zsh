MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'
MAIN_DOT="${MAIN_ALIAS}${KEYMAP_DOT}"

# Find keymap scripts
MAIN_KEYMAP=(); while IFS='' read -r line; do MAIN_KEYMAP+=("$line"); done < <(
	find "$ZSHRC_DIR" -maxdepth 1 -name '*_keymap.zsh' | sort | while IFS= read -r file; do
		current_namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")

		# Exclude `_keymap.zsh` helpers via the fact that it doesn't have a namespace
		[[ -z $current_namespace ]] && continue

		current_alias=$(pgrep --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")
		echo "$current_alias # Show \`$current_namespace\`" | bw
	done
)

# Append keymap snapshots
MAIN_KEYMAP+=( # TODO create these keymaps
	''
#	"${MAIN_DOT}s # Show system default keymap"
#	''
#	"${MAIN_DOT}i # Show IntelliJ \`cmd\` keymap"
#	"${MAIN_DOT}ic # Show IntelliJ \`ctrl\` keymap"
#	"${MAIN_DOT}ia # Show IntelliJ \`alt\` keymap"
#	"${MAIN_DOT}if # Show IntelliJ \`fn\` keymap"
#	''
	"${MAIN_DOT}k # List keymap entries"
	"${MAIN_DOT}k <key> # Filter keymap entries"
	"${MAIN_DOT}k <namespace> <key> # Filter keymap entries"
	''
#	"${MAIN_DOT}m # Show TextMate keymap"
#	"${MAIN_DOT}n # Show Notion keymap"
#	"${MAIN_DOT}t # Show Terminal keymap"
	"${MAIN_DOT}vv # Show Vimium / Vimari keymap"
	"${MAIN_DOT}vs # Show Vimium search keymap"
#	''
#	"${MAIN_DOT}ki # Show Kinesis keymap"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

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

function main_keymap_vs {
	cat "$DOTFILES_DIR"/vimium/vimium-searches.txt
}

function main_keymap_vv {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
