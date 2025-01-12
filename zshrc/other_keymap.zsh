OTHER_NAMESPACE='other_keymap'
OTHER_ALIAS='o'

OTHER_KEYMAP=(
	"$OTHER_ALIAS${KEYMAP_DOT}i # Open current directory in IntelliJ IDEA"
	"$OTHER_ALIAS${KEYMAP_DOT}i <path> # Open target directory in IntelliJ IDEA"
	"$OTHER_ALIAS${KEYMAP_DOT}m # Open current directory in TextMate"
	"$OTHER_ALIAS${KEYMAP_DOT}m <path> # Open target directory in TextMate"
	"$OTHER_ALIAS${KEYMAP_DOT}o # Open current directory in Finder"
	"$OTHER_ALIAS${KEYMAP_DOT}o <path> # Open target directory in Finder"
)

keymap_init $OTHER_NAMESPACE $OTHER_ALIAS "${OTHER_KEYMAP[@]}"

function other_keymap {
	directory="$1"

	# TODO add test
	if [[ -d "$directory" ]]; then
		cd "$directory" || return
		other_keymap_n
		return
	fi

	keymap_invoke $OTHER_NAMESPACE $OTHER_ALIAS ${#OTHER_KEYMAP} "${OTHER_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function other_keymap_i {
	local target_path=${*:-.}

	open -na 'IntelliJ IDEA CE.app' --args "$target_path"
}

function other_keymap_m {
	local target_path=${*:-.}

	mate "$target_path"
}

function other_keymap_o {
	local target_path=${*:-.}

	open "$target_path"

#	local target=$*
#
#	[[ -z $target ]] && open . && return
#	[[ -d $target ]] && open "$target" && return
#	[[ -f $target ]] && open "$target" && return
#
#	echo "$target" | extract_urls | bw | while IFS= read -r url; do open "$url"; done
}
