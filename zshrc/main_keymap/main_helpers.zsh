function main_keymap_find_keymaps_by_type {
	reply_zsh_keymaps=()
	reply_non_zsh_keymaps=()
	local is_zsh_keymap
	local current_namespace
	local current_alias

	keymap_files | while IFS= read -r file; do
		# Zsh keymaps have a `_DOT` variable used by key mappings
		is_zsh_keymap=$(egrep --only-matching "[A-Z]+_DOT=\"" "$file")

		current_namespace=$(pgrep --color=never --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")
		current_alias=$(pgrep --color=never --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")

		if [[ -n $is_zsh_keymap ]]; then
			# shellcheck disable=SC2030
			reply_zsh_keymaps+=("$current_alias # Show \`$current_namespace\`")
		else
			# shellcheck disable=SC2030
			reply_non_zsh_keymaps+=("$current_alias # Show \`$current_namespace\`")
		fi
	done
}

function main_keymap_find_key_mappings_by_type {
	local description=$*

	local keymaps; keymaps=$(keymap_names)

	# Declare vars used in `while` loop
	reply_zsh_mappings=()
	reply_non_zsh_mappings=()
	local entries
	local non_zsh_namespace

	# shellcheck disable=SC2034 # Used to define `entries`
	while IFS= read -r keymap; do
		# shellcheck disable=SC2206 # Adding double quote breaks array expansion
		entries=(${(P)keymap})
		# Note: ^ `entries=("${(P)$(echo "$keymap")[@]}")` actually works
		# But it's convoluted, and it leaves in the empty entries, which we do not want

		# Find keymap entries with matching description
		setopt nocasematch
		if keymap_has_dot_alias "${entries[@]}"; then
			for entry in "${entries[@]}"; do
				# shellcheck disable=SC2076
				if [[ -z $description || $entry =~ ".* # .*$description.*" ]]; then
					reply_zsh_mappings+=("$entry")
				fi
			done
		else
			# Unlike zsh entries, non-zsh entries lack a leading alias to indicate namespace
			non_zsh_namespace=$(echo "${keymap%_KEYMAP}" | downcase)

			for entry in "${entries[@]}"; do
				# shellcheck disable=SC2076
				if [[ -z $description || $entry =~ ".* # .*$description.*" ]]; then
					reply_non_zsh_mappings+=("$non_zsh_namespace: $entry")
				fi
			done
		fi
		unsetopt nocasematch
	done <<< "$keymaps"
}

function main_keymap_extract {
	local keymap_name=$1

	main_keymap_find_keymaps_by_type

	# Open keymap array
	local extracted="$keymap_name=(\n"

	# Populate keymap array

	# shellcheck disable=SC2031
	for keymap in "${reply_zsh_keymaps[@]}"; do
		extracted+="\t'$keymap'\n"
	done

	extracted+="\t''\n"

	# shellcheck disable=SC2031
	for keymap in "${reply_non_zsh_keymaps[@]}"; do
		extracted+="\t'$keymap'\n"
	done

	# Close keymap array
	extracted+=')'

	# Refresh extracted keymap
	echo $extracted > "$ALL_KEYMAP_FILE"
}

function main_keymap_print_keyboard_shortcuts {
	local keymap_name=$1; shift
	local keymap_entries=("$@")

	local is_zsh_keymap=0
	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${keymap_entries[@]}")

	echo
	echo "$keymap_name"
	echo

	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
	done
}
