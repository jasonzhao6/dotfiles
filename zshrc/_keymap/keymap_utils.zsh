#
# This file contains one-off functions not used by `keymap_init, keymap_invoke`
#

function keymap_files {
	ls "$ZSHRC_DIR"/**/*_keymap.zsh | bw | grep --invert-match _tests
	# Note: ^ `ls "$ZSHRC_DIR"/**!(_tests)/*_keymap.zsh` works in the current shell
	# But it isn't working in the tests subshell even with `setopt EXTENDED_GLOB`
}

function keymap_names {
	# No need to exclude `TEST_KEYMAP` b/c it's not sourced when not testing
	pgrep --only-matching "^[A-Z_]+_KEYMAP(?==\($)" "$ZSHRC_DIR"/**/*_keymap*.zsh |
		bw |
		sed 's/^[^:]*://'
}

# Used to perform per-keymap filtering, e.g `m.- {match}* {-mismatch}*`
function keymap_filter_entries {
	local namespace=$1; shift
	local filters=("$@")

	local entries=("${(P)$(echo "$namespace" | upcase)[@]}")
	local is_zsh_keymap; keymap_has_dot_alias "${entries[@]}" && is_zsh_keymap=1
	local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries[@]}")

	local output; output=$(
		for entry in "${entries[@]}"; do
			keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
		done
	)

	echo
	echo "$output" | bw | strip_left | args_keymap_s "${filters[@]}"
}

function keymap_print_entries {
	local is_zsh_keymap=$1; shift
	local entries=("$@")

	[[ -z ${entries[*]} ]] && return

	local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries[@]}")

	echo
	for entry in "${entries[@]}"; do
		keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
	done
}
