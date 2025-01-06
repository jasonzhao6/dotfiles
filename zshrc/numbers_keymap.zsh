##
## Namespace: [N]umbers
##
#
#NUMBERS_KEYMAP=(
#)
#
#function n {
#	local namespace='o'
#	local output; output="$(keymap $namespace ${#OPENS_KEYMAP} "${OPENS_KEYMAP[@]}" "$@")"
#	local exit_code=$?; [[ $exit_code -eq 0 ]] && echo "$output" | ss || echo "$output"
#}
#
##
## Key mappings
##
