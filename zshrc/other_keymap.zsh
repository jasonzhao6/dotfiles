OTHER_NAMESPACE='other_keymap'
OTHER_ALIAS='o'

OTHER_KEYMAP=(
	"$OTHER_ALIAS <path> # Open the specified path in Finder"
	"$OTHER_ALIAS <urls> # Open urls from a string"
	''
	"$OTHER_ALIAS${KEYMAP_DOT}i # Open the current path in IntelliJ IDEA"
	"$OTHER_ALIAS${KEYMAP_DOT}i <path> # Open the specified path in IntelliJ IDEA"
	"$OTHER_ALIAS${KEYMAP_DOT}m # Open the current path in TextMate"
	"$OTHER_ALIAS${KEYMAP_DOT}m <path> # Open the specified path in TextMate"
	"$OTHER_ALIAS${KEYMAP_DOT}o # Open the current path in Finder"
	"$OTHER_ALIAS${KEYMAP_DOT}o <path> # Open the specified path in Finder"
	"$OTHER_ALIAS${KEYMAP_DOT}o <urls> # Open urls from a string"
)

keymap_init $OTHER_NAMESPACE $OTHER_ALIAS "${OTHER_KEYMAP[@]}"

function other_keymap {
	local target=$*

	[[ -n $target ]] && other_keymap_o "$target" && return

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
	local target=$*

	# If target is empty, open the current directory
	[[ -z $target ]] && open . && return

	# If target is a local directory or file, open it
	[[ -d $target ]] && open "$target" && return
	[[ -f $target ]] && open "$target" && return

	# If target is a list of urls, open them
	local has_urls
	while IFS= read -r url; do
		[[ -z $url ]] && continue

		has_urls=1
		open "$url"
	done <<< "$(echo "$target" | extract_urls | bw)"
	[[ -n $has_urls ]] && return

	# If we didn't open anything, return exit code `1`
	return 1
}
