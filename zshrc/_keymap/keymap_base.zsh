#
# The files contains the main keymap functions, `keymap_init, keymap_invoke`, and their helpers
#

KEYMAP_COLOR='cyan_fg'
KEYMAP_PROMPT=$($KEYMAP_COLOR '  $')
KEYMAP_ALIAS='_PLACEHOLDER_'
KEYMAP_DASH='-'
KEYMAP_DOT='.'
KEYMAP_DOT_POINTER='^'
KEYMAP_ESCAPE="\\\\" # Escape twice to avoid special chars like `\n`

KEYMAP_USAGE=(
	"${KEYMAP_ALIAS} # Show this help"
	''
	"${KEYMAP_ALIAS}${KEYMAP_DOT}{key} # Invoke {key} mapping"
	"${KEYMAP_ALIAS}${KEYMAP_DOT}{key} {arg} # Invoke {key} mapping with {arg}"
	''
	"${KEYMAP_ALIAS}${KEYMAP_DOT}- # List key mappings in this namespace"
	"${KEYMAP_ALIAS}${KEYMAP_DOT}- {match}* {-mismatch}* # Filter key mappings in this namespace"
)

function keymap_init {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	keymap_set_alias "$alias" "$namespace"

	keymap_set_alias "$alias-" "keymap_filter_entries $namespace"

	keymap_has_disjoint_dups "$namespace" "${keymap_entries[@]}" && return

	if keymap_has_dot_alias "${keymap_entries[@]}"; then
		keymap_set_dot_aliases "$alias" "$namespace" "${keymap_entries[@]}"
	fi
}

function keymap_invoke {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_size=$1; shift
	local keymap_entries=("${@:1:$keymap_size}"); shift "$keymap_size"
	local key=$1; [[ -n $key ]] && shift
	local args=("$@")

	# If a `key` was not specified, print usage
	[[ -z $key ]] && keymap_print_help "$namespace" "$alias" "${keymap_entries[@]}" && return

	# Every keymap has an implicit `-` key set up by `keymap_init`
	[[ $key == '-' ]] && eval "$alias- ${args[*]}" && return

	# If found, invoke it with the specified `args`
	if keymap_is_key_mapped "$alias" "$key" "${keymap_entries[@]}"; then
		"${namespace}_${key}" "${args[@]}"

	# If not found, print error
	else
		echo
		red_bar "\`$key\` key does not exist in \`$namespace\`"
	fi
}

#
# Helpers
#

# Example:
#   ```
#   hc       # Open tab to the latest commit
#   hc {sha} # Open tab to the specified commit  <--  Joint duplicate, likely intentional
#
#   ha       # Do something
#   hc       # Do something else                 <--  Disjoint duplicate, likely a mistake
#   ```
function keymap_has_disjoint_dups {
	local namespace=$1; shift
	local entries=("$@")

	local last_entry
	local has_disjoint_dups
	declare -A seen

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

		# Otherwise, report on disjoint dups
		else
			echo
			red_bar "\`$namespace\` has duplicate \`$alias_dot_key\` entries"
			has_disjoint_dups=1
		fi
	done

	[[ -n $has_disjoint_dups ]] && return 0 || return 1
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

function keymap_set_dot_aliases {
	local alias=$1; shift
	local namespace=$1; shift
	local keymap_entries=("$@")

	local first_token
	local key
	declare -A seen

	for entry in "${keymap_entries[@]}"; do
		first_token="${${(z)entry}[1]}"

		# Set alias only for `key`s preceded by `KEYMAP_DOT`s
		[[ $first_token != *$KEYMAP_DOT* ]] && continue

		# Extract `key` from `entry`
		key="${first_token#*$KEYMAP_DOT}"

		# Alias each `key` once
		if [[ -z ${seen[$key]} ]]; then
			seen[$key]=1

			keymap_set_alias "${alias}${key}" "${namespace}_${key}"
		fi
	done
}

function keymap_print_help {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	local is_zsh_keymap; keymap_has_dot_alias "${keymap_entries[@]}" && is_zsh_keymap=1

	# `ALL_NAMESPACE` is an exception that does not have dot aliases
	[[ $namespace == "$ALL_NAMESPACE" ]] && is_zsh_keymap=1

	echo
	echo Keymap
	echo

	$KEYMAP_COLOR "  $namespace"
	keymap_print_map "$namespace" "${keymap_entries[@]}"

	# If it's `ALL_NAMESPACE` or a non-zsh keymap, skip printing command line usage
	local max_command_size
	local keymap_usage=()
	if [[ $namespace == "$ALL_NAMESPACE" || $is_zsh_keymap -ne 1 ]]; then
		max_command_size=$(keymap_get_max_command_size "${keymap_entries[@]}")
	else
		# Interpolate `alias` into `KEYMAP_USAGE`
		for entry in "${KEYMAP_USAGE[@]}"; do
			keymap_usage+=("${entry/$KEYMAP_ALIAS/$alias}")
		done

		max_command_size=$(keymap_get_max_command_size "${keymap_usage[@]}" "${keymap_entries[@]}")

		echo
		echo Usage
		echo

		for entry in "${keymap_usage[@]}"; do
			keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
		done

		keymap_annotate_the_dot "$alias" "$max_command_size"
	fi

	echo
	echo Mappings
	echo

	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
	done
}

# Zsh keymaps should avoid these chars
# - `'` b/c it begins a new quote in zsh
# - `.` b/c it's already used as `KEYMAP_DOT`
# - `;` b/c it begins a new command in zsh
#
# shellcheck disable=SC2034 # Used via `KEYMAP_PRINT_ROW_${i}`
{
	KEYMAP_PRINT_ROW_1=('`' '1' '2' '3' '4' '5' '|' '6' '7' '8' '9' '0' '[' ']')
	KEYMAP_PRINT_ROW_2=(' ' "'" ',' '.' 'p' 'y' '|' 'f' 'g' 'c' 'r' 'l' '/' '=' "$KEYMAP_ESCAPE")
	KEYMAP_PRINT_ROW_3=(' ' 'a' 'o' 'e' 'u' 'i' '|' 'd' 'h' 't' 'n' 's' '-')
	KEYMAP_PRINT_ROW_4=(' ' ';' 'q' 'j' 'k' 'x' '|' 'b' 'm' 'w' 'v' 'z')
}

function keymap_print_map {
	local namespace=$1; shift
	local keymap_entries=("$@")

	declare -A namespace_aliases
	declare -A keymap_initials
	local first_token
	local key_initial
	local escaped_initial

	# Identify the key initial for each entry
	# - If it follows a `KEYMAP_DOT`, it's a key mapping- use the first character after `KEYMAP_DOT`
	# - If it follows a `KEYMAP_DASH`, it's a keyboard shortcut- use the last character
	# - If it's a key mapping to other keymaps, capture it separately
	# - Otherwise, use the first character
	for entry in "${keymap_entries[@]}"; do
		# Reset; otherwise, an empty line will increment the previous initial
		first_token=
		key_initial=
		escaped_initial=

		if [[ $entry == *\#* ]]; then
			first_token=${${(z)entry}[1]}
		else
			first_token=$entry
		fi

		# Check `KEYMAP_DASH` before `KEYMAP_DOT` to account for keyboard shortcuts like `cmd-.`
		if [[ $first_token == *$KEYMAP_DASH* ]]; then
			key_initial=${first_token: -1}
		elif [[ $first_token == *$KEYMAP_DOT* ]]; then
			key_initial=${${first_token#*$KEYMAP_DOT}:0:1}
		elif [[ $namespace == 'main_keymap' ]]; then
			namespace_aliases[$first_token]=1
		else
			key_initial=${first_token:0:1}
		fi

		if [[ -n $key_initial ]]; then
			# Some keys such as `[` can only be used as a hash key when escaped
			# It doesn't hurt to escape all key initials, so doing that to avoid conditional handling
			escaped_initial="$KEYMAP_ESCAPE$key_initial"

			keymap_initials["$escaped_initial"]=$((${keymap_initials["$escaped_initial"]} + 1))
		fi
	done

	# Print a map of key initials
	# - If a key maps to other keymaps, print with `()` in keymap theme color
	# - If a key maps to multiple mapping functions, print with `()`
	# - If a key maps to one mapping function, print with `<>`
	# - If a key is unused, print in gray
	local row_input
	local row_output
	for i in {1..4}; do
		# shellcheck disable=SC2034 # Use via `${(P)row_input}`
		row_input=KEYMAP_PRINT_ROW_${i}
		row_output+="\n "

		for char in ${(P)row_input}; do
			escaped_initial="$KEYMAP_ESCAPE$char"

			# The `\` char doesn't work without an extra layer of escaping
			[[ $char == "$KEYMAP_ESCAPE" ]] && escaped_initial="$KEYMAP_ESCAPE\\"

			if [[ $char == '_' ]]; then
				row_output+='    '
			elif [[ -n ${namespace_aliases[$char]} ]]; then
				row_output+=" $($KEYMAP_COLOR "($char)")"
			elif [[ -z ${keymap_initials["$escaped_initial"]} ]]; then
				row_output+="  $(gray_fg "$char") "
			elif [[ ${keymap_initials["$escaped_initial"]} -eq 1 ]]; then
				row_output+=" <$char>"
			else
				row_output+=" ($char)"
			fi
		done
	done
	echo "$row_output"

	# Print keymap legend
	echo
	gray_fg '   `<>` key initials have one mapping'
	gray_fg '   `()` key initials have multiple mappings'
}

function keymap_print_entry {
	local entry=$1
	local is_zsh_keymap=$2
	local command_size=$3

	# If `entry` does not start `#`, extract `command`
	local command; [[ $entry != \#* ]] && command="${entry%% \#*}"

	# If `entry` contains `#`, extract `comment`
	local comment; [[ $entry == *\#* ]] && comment="# ${entry#*\# }"

	# If it's a zsh keymap, print `prompt`; otherwise, do not
	local prompt=$KEYMAP_PROMPT
	[[ $is_zsh_keymap -ne 1 ]] && prompt=' '

	# If command is a non-zsh keymap that contains `\` escape char, do not print it
	command=${command/-\\/-}

	# Print with color
	if [[ -n $command || -n $comment ]]; then
		printf "%s %-*s %s\n" "$prompt" "$command_size" "$command" "$(gray_fg "$comment")"

	# Allow empty line as separators between different sections of a keymap
	else
		echo
	fi
}

# Get the max command size in order to align comments across commands, e.g
#   ```
#   $ {key}       # Comment 1
#   $ {key} {arg} # Comment 2
#   ```
function keymap_get_max_command_size {
	local entries=("$@")

	local max_command_size=0
	local command_size

	for entry in "${entries[@]}"; do
		# If `entry` starts with `#`, this enry does not have any command
		[[ $entry == \#* ]] && command_size=0 || command_size="${#entry% \#*}"

		[[ $command_size -gt $max_command_size ]] && max_command_size=$command_size
	done

	echo "$max_command_size"
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
		"$(gray_fg "# \`$KEYMAP_DOT\` represents an optional space character")"
	printf "%-*s %-*s %s\n" \
		$(($(echo -n "$KEYMAP_PROMPT" | bw | wc -c) + ${#alias})) \
		'' \
		"$((command_size - ${#alias}))" \
		'' \
		"$(gray_fg "# E.g To invoke \`a${KEYMAP_DOT}b\`, use either \`ab\` or \`a b\`")"
}

function keymap_has_dot_alias {
	local entries=("$@")

	for entry in "${entries[@]}"; do
		# shellcheck disable=SC2076
		[[ $entry =~ ".+\\$KEYMAP_DOT.+ # .+" ]] && return 0
	done

	return 1
}

function keymap_is_key_mapped {
	local alias=$1; shift
	local key=$1; shift
	local keymap_entries=("$@")

	for entry in "${keymap_entries[@]}"; do
		[[ $entry == "$alias$KEYMAP_DOT$key"* ]] && return 0
	done

	return 1
}
