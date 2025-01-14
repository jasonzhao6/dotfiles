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
	"${MAIN_DOT}k <key> # List keymap entries"
	''
#	"${MAIN_DOT}m # Show TextMate keymap"
#	"${MAIN_DOT}n # Show Notion keymap"
#	"${MAIN_DOT}t # Show Terminal keymap"
	"${MAIN_DOT}vv # Show Vimium / Vimari keymap"
	"${MAIN_DOT}vs # Show Vimium search keymap"
#	''
#	"${MAIN_DOT}k # Show Kinesis keymap"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function main_keymap_vs {
	cat "$DOTFILES_DIR"/vimium/vimium-searches.txt
}

function main_keymap_vv {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
