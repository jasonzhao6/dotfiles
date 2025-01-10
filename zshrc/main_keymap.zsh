MAIN_NAMESPACE='main_keymap'
MAIN_ALIAS='m'

# Find scripted keymaps
MAIN_KEYMAP=(); while IFS='' read -r line; do MAIN_KEYMAP+=("$line"); done < <(
	find "$ZSHRC_DIR" -maxdepth 1 -name '*_keymap.zsh' | sort | while IFS= read -r file; do
		current_namespace=$(pgrep --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")
		[[ -z $current_namespace ]] && continue

		current_alias=$(pgrep --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")
		echo "$current_alias # Show \`$current_namespace\`" | bw
	done
)

# Append snapshotted keymaps
MAIN_KEYMAP+=(
	''
	"$MAIN_ALIAS·i # Show IntelliJ \`cmd\` keymap" # TODO
	"$MAIN_ALIAS·ic # Show IntelliJ \`ctrl\` keymap"
	"$MAIN_ALIAS·ia # Show IntelliJ \`alt\` keymap"
	"$MAIN_ALIAS·if # Show IntelliJ \`fn\` keymap"
	"$MAIN_ALIAS·t # Show TextMate keymap"
	''
	"$MAIN_ALIAS·k # Show Kinesis keymap"
	''
	"$MAIN_ALIAS·vv # Show Vimium / Vimari keymap"
)

keymap_init $MAIN_NAMESPACE $MAIN_ALIAS "${MAIN_KEYMAP[@]}"

function main_keymap {
	keymap_invoke $MAIN_NAMESPACE $MAIN_ALIAS ${#MAIN_KEYMAP} "${MAIN_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function main_keymap_b {
	cat "$DOTFILES_DIR"/vimium/vimium-keymap.txt
}
