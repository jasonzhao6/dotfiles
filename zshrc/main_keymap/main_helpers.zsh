# shellcheck disable=SC2116 # Removing echo breaks array interpolation by name
function main_keymap_show_default_keyboard_shortcuts {
	local name=$1; shift
	local description=$*

	local is_zsh_keymap=0
	local namespace; namespace=$(echo "${name}_KEYMAP" | upcase)
	local keymap_entries; keymap_entries=("${(P)$(echo "$namespace")[@]}")

	if [[ -z $description ]]; then
		echo
		echo -n 'Shortcuts: '
		cyan_fg "$MAIN_NAMESPACE.$name.zsh"

		main_keymap_print_key_mappings $is_zsh_keymap "${keymap_entries[@]}"
	else
		keymap_filter_entries "$namespace" "$description"
	fi
}

function main_keymap_print_key_mappings {
	local is_zsh_keymap=$1; shift
	local keymap_entries=("$@")

	[[ -z ${keymap_entries[*]} ]] && return

	local max_command_size; max_command_size=$(keymap_get_max_command_size "${keymap_entries[@]}")

	echo
	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
	done
}

function main_keymap_extract_keymaps {
	local keymap_name=$1

	main_keymap_find_keys

	# Open keymap array
	local extracted="$keymap_name=(\n"

	#
	# Populate keymap array
	#

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

function main_keymap_find_keys {
	reply_zsh_keymaps=()
	reply_non_zsh_keymaps=()

	local is_zsh_keymap
	local current_namespace
	local current_alias

	while IFS= read -r file; do
		# Zsh keymaps have a `_DOT` variable used by key mappings
		is_zsh_keymap=$(egrep --only-matching "[A-Z]+_DOT=\"" "$file")

		current_namespace=$(pgrep --color=never --only-matching "(?<=_NAMESPACE=')\w+(?=')" "$file")
		current_alias=$(pgrep --color=never --only-matching "(?<=_ALIAS=')\w+(?=')" "$file")

		if [[ -n $is_zsh_keymap ]]; then
			# shellcheck disable=SC2030
			reply_zsh_keymaps+=("$current_alias # Custom aliases: $current_namespace.zsh")
		else
			# shellcheck disable=SC2030
			reply_non_zsh_keymaps+=("$current_alias # Custom shortcuts: $current_namespace.zsh")
		fi
	done < <(keymap_files)
}

function main_keymap_find_key_mappings {
	local description=$*
	reply_zsh_mappings=()
	reply_non_zsh_mappings=()

	local keymaps; keymaps=$(main_keymap_grep_keymap_names)

	local keymap_entries
	local non_zsh_name

	# shellcheck disable=SC2034 # Used to define `keymap_entries`
	while IFS= read -r keymap; do
		# shellcheck disable=SC2206 # Adding double quote breaks array expansion
		keymap_entries=(${(P)keymap})

		# Find keymap keymap_entries with matching description
		setopt nocasematch
		if keymap_has_dot_alias "${keymap_entries[@]}"; then
			for entry in "${keymap_entries[@]}"; do
				# shellcheck disable=SC2076
				if [[ -z $description || $entry =~ ".* # .*$description.*" ]]; then
					reply_zsh_mappings+=("$entry")
				fi
			done
		else
			# Unlike zsh keymap_entries, non-zsh keymap_entries lack a leading alias to indicate namespace
			non_zsh_name=$(echo "${keymap%_KEYMAP}" | downcase)

			for entry in "${keymap_entries[@]}"; do
				# shellcheck disable=SC2076
				if [[ -z $description || $entry =~ ".* # .*$description.*" ]]; then
					reply_non_zsh_mappings+=("$non_zsh_name: $entry")
				fi
			done
		fi
		unsetopt nocasematch
	done <<< "$keymaps"
}
