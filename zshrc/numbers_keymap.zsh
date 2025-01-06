##
## Namespace: [N]umbers
##
#
#NUMBERS_USAGE=(
#	'n # Show this help'
#	'n <key> <args>* # Invoke a key mapping'
#)
#
#NUMBERS_KEYMAP=(
#)
#
#function n {
#	local output; output="$(keymap_invoke ${#NUMBERS_KEYMAP} "${NUMBERS_KEYMAP[@]}" 'n' "$@")"
#
#	if [[ -n $output ]]; then
#		echo "$output" | ss
#	else
#		keymap_help ${#NUMBERS_USAGE} "${NUMBERS_USAGE[@]}" "${NUMBERS_KEYMAP[@]}"
#	fi
#}
#
##
## Key mappings
##
