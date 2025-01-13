KEYMAP_COLOR='cyan_fg'
KEYMAP_PROMPT=$($KEYMAP_COLOR '  $')
KEYMAP_PROMPT_BLANK=$(printf "%$(size_of "$KEYMAP_PROMPT")s")
KEYMAP_ALIAS='_PLACEHOLDER_'
KEYMAP_DOT='.'
KEYMAP_DOT_POINTER='^'

KEYMAP_USAGE=(
	"$KEYMAP_ALIAS # Show this help"
	''
	"$KEYMAP_ALIAS$KEYMAP_DOT<key> # Invoke <key>"
	"$KEYMAP_ALIAS$KEYMAP_DOT<key> <arg> # Invoke <key> with <arg>"
)

function keymap_init {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	# If `keymap_entries` contains disjoint duplicate `key`s, abort
	keymap_error_on_disjoint_dupes "${keymap_entries[@]}" || return

	# Alias the `<namespace>` function to `<alias>`
	keymap_set_alias "$alias" "$namespace"

	# Alias the `<namespace>_<key>` functions to `<alias><key>`
	while IFS= read -r key; do
		keymap_set_alias "$alias$key" "${namespace}_$key"
	done <<< "$(keymap_extract_uniq_keys "${#alias}" "${keymap_entries[@]}")"
}

function keymap_invoke {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_size=$1; shift
	local keymap_entries=("${@:1:$keymap_size}"); shift "$keymap_size"
	local key=$1; [[ -n $key ]] && shift
	local args=("$@")

	# If a `key` was not specified, print usage
	[[ -z $key ]] && keymap_help "$namespace" "$alias" "${keymap_entries[@]}" && return

	# Look for the specified `key`
	local found
	for entry in "${keymap_entries[@]}"; do
		[[ $entry == "$alias$KEYMAP_DOT$key"* ]] && found=1 && break
	done

	# If not found, print error
	if [[ -z $found ]]; then
		echo
		red_bar "A \`$key\` key does not exist in \`$namespace\`"
		return

	# If found, invoke it with the specified `args`
	else
		"${namespace}_${key}" "${args[@]}"
	fi
}

#
# Helpers
#

# ```
# hc       # Open tab to the latest commit
# hc <sha> # Open tab to the specified commit  <--  Joint duplicate, likely intentional
#
# ha       # Do something
# hc       # Do something else                 <--  Disjoint duplicate, likely a mistake
# ```
function keymap_error_on_disjoint_dupes {
	local entries=("$@")
	local last_entry
	local has_disjoint_dupes

	typeset -A seen

	for entry in "${entries[@]}"; do
		alias_dot_key="${${(z)entry}[1]}"

		# If it is the same as the last entry, allow it
		if [[ $alias_dot_key == "$last_entry" ]]; then
			continue

		# Otherwise, remember it to allow dupe in the next entry
		else
			last_entry=$alias_dot_key
		fi

		# If we have not seen an entry, remember it
		if [[ -z ${seen[$alias_dot_key]} ]]; then
			seen[$alias_dot_key]=$entry

		# Otherwise, report on disjoint dupes
		else
			echo
			red_bar "\`$alias_dot_key\` has duplicate key mappings"
			has_disjoint_dupes=1
		fi
	done

	[[ -n $has_disjoint_dupes ]] && return 1 || return 0
}

function keymap_set_alias {
	local key=$1
	local value=$2

	# Do not overwrite reserved keywords, error instead
	if is_reserved "$key"; then
		echo
		red_bar "\`$key\` is a reserved keyword"
		return
	fi

	# shellcheck disable=SC2086,SC2139
	alias $key="$value"
}

function keymap_help {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	# Interpolate `alias` into keymap usage
	local keymap_usage=()
	for entry in "${KEYMAP_USAGE[@]}"; do
		keymap_usage+=("${entry/$KEYMAP_ALIAS/$alias}")
	done

	# Get the max command size in order to align comments across commands, e.g
	#   ```
	#   $ <key>       # comment 1
	#   $ <key> <arg> # comment 2
	#   ```
	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${keymap_usage[@]}" "${keymap_entries[@]}")

	echo
	echo 'Name'
	echo

	$KEYMAP_COLOR "  $namespace"
	keymap_print "$namespace" "$alias" "${keymap_entries[@]}"

	echo
	echo 'Usage'
	echo

	for entry in "${keymap_usage[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done

	keymap_annotate_the_dot "$alias" "$max_command_size"

	echo
	echo 'Keymap'
	echo

	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}

function keymap_get_max_command_size {
	local entries=("$@")

	local max_command_size=0
	local command_size

	for entry in "${entries[@]}"; do
		# If `entry` starts with `#`, there is no command
		[[ $entry = \#* ]] && command_size=0 || command_size="${#entry% \#*}"

		[[ $command_size -gt $max_command_size ]] && max_command_size=$command_size
	done

	echo "$max_command_size"
}

# shellcheck disable=SC2034 # Used via `KEYMAP_PRINT_ROW_${i}`
KEYMAP_PRINT_ROW_1=(_ _ _ p y \| f g c r l)
# shellcheck disable=SC2034 # Used via `KEYMAP_PRINT_ROW_${i}`
KEYMAP_PRINT_ROW_2=(a o e u i \| d h t n s)
# shellcheck disable=SC2034 # Used via `KEYMAP_PRINT_ROW_${i}`
KEYMAP_PRINT_ROW_3=(_ q j k x \| b m w v z)

function keymap_print {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	# For the current keymap, count the number of keys per key initial
	typeset -A current_keymap_keys
	local key_initial
	while IFS= read -r key; do
		key_initial=${key:0:1}

		current_keymap_keys[$key_initial]=$((current_keymap_keys[$key_initial] + 1))
	done <<< "$(keymap_extract_uniq_keys "${#alias}" "${keymap_entries[@]}")"

	# If this is the `main_keymap`, catalog the keys to other keymaps
	typeset -A main_keymap_keys
	if [[ $namespace == 'main_keymap' ]]; then
		while IFS= read -r key; do
			main_keymap_keys[$key]=1
		done <<< "$(keymap_extract_namespace_keys "${keymap_entries[@]}")"
	fi

	# Print a map of key initials
	# - Print keys to other keymaps as yellow
	# - Print used keys with a single mapping as white
	# - Print used keys with multiple mappings as white with a `+` suffix
	# - Print unused keys as gray
	local row_input
	local row_output
	for i in {1..3}; do
		# shellcheck disable=SC2034 # Use via `${(P)row_input}`
		row_input=KEYMAP_PRINT_ROW_${i}
		row_output+="\n "

		for char in ${(P)row_input}; do
			if [[ $char == '_' ]]; then
				row_output+='    '
			elif [[ -n ${main_keymap_keys[$char]} ]]; then
				row_output+=" $($KEYMAP_COLOR "[$char]")"
			elif [[ -z ${current_keymap_keys[$char]} ]]; then
				row_output+="  $(gray_fg "$char") "
			elif [[ ${current_keymap_keys[$char]} -eq 1 ]]; then
				row_output+=" <$char>"
			else
				row_output+=" [$char]"
			fi
		done
	done
	echo "$row_output"

	# Print keymap legend
	echo
	gray_fg '   <> indicates key has one mapping function'
	gray_fg '   [] indicates key has multiple mapping function'
}

function keymap_print_entry {
	local entry=$1
	local command_size=$2

	local prompt=$KEYMAP_PROMPT

	# If `entry` starts with `#`, there is no command
	local command; [[ $entry = \#* ]] || command="${entry% \#*}"

	# If `command` is blank, make `prompt` blank too
	[[ -z $command ]] && prompt=$KEYMAP_PROMPT_BLANK

	# If `entry` contains `#`, extract `comment`
	local comment; [[ $entry = *\#* ]] && comment="# ${entry#*\# }"

	# Print with color
	if [[ -n $command || -n $comment ]]; then
		printf "%s %-*s %s\n" "$prompt" "$command_size" "$command" "$(gray_fg "$comment")"

	# Allow empty line as separators between different sections of a keymap
	else
		echo
	fi
}

function keymap_extract_uniq_keys {
	local alias_size=$1; shift
	local keymap_entries=("$@")

	local cut_start=$((alias_size + 2))

	for entry in "${keymap_entries[@]}"; do
		[[ $entry == *$KEYMAP_DOT* ]] && echo "$entry"
	done | awk '{print $1}' | cut -c $cut_start- | uniq
}

function keymap_extract_namespace_keys {
	local keymap_entries=("$@")

	for entry in "${keymap_entries[@]}"; do
		[[ $entry != *$KEYMAP_DOT* ]] && echo "$entry"
	done | awk '{print $1}'
}

function keymap_annotate_the_dot {
	local alias=$1
	local command_size=$2

	echo
	printf "%-*s %s%-*s %s\n" \
		$(($(echo -n "$KEYMAP_PROMPT" | bw | wc -c) + ${#alias})) \
		'' \
		"$(gray_fg "$KEYMAP_DOT_POINTER")" \
		"$((command_size - ${#alias} - ${#KEYMAP_DOT_POINTER}))" \
		'' \
		"$(gray_fg "# The $KEYMAP_DOT represents an optional space")"
}
