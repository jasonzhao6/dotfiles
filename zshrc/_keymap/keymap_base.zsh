KEYMAP_PROMPT=$(cyan_fg '  $ ')
KEYMAP_ALIAS='_PLACEHOLDER_'
KEYMAP_DASH='-'
KEYMAP_DOT='.'
KEYMAP_DOT_POINTER='^'
KEYMAP_PIPE_PATTERN="(|)? "
KEYMAP_ESCAPE="\\\\" # Escape twice to avoid special chars like `\n`

KEYMAP_USAGE=(
	"${KEYMAP_ALIAS} # Show this keymap"
	"${KEYMAP_ALIAS} <regex> # Search this keymap"
	''
	"${KEYMAP_ALIAS}${KEYMAP_DOT}<key> # This mapping takes no variable"
	"${KEYMAP_ALIAS}${KEYMAP_DOT}<key> <var> # This mapping takes one variable"
	"${KEYMAP_ALIAS}${KEYMAP_DOT}<key> <var>? # This mapping takes zero or one variable"
	"${KEYMAP_ALIAS}${KEYMAP_DOT}<key> <var>* # This mapping takes zero or multiple variables"
	"${KEYMAP_ALIAS}${KEYMAP_DOT}<key> (1-10) # This mapping takes an exact value from the list"
	"(|)? ${KEYMAP_ALIAS}${KEYMAP_DOT}<key> # This mapping can be invoked after a \`|\`"
)

function keymap_init {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	keymap_has_disjoint_dups "$namespace" "${keymap_entries[@]}" && return

	keymap_set_alias "$alias" "$namespace"

	# Terminal keymaps have dot aliases; IntelliJ/Vimium keymaps do not
	if keymap_has_dot_alias "${keymap_entries[@]}"; then
		keymap_set_dot_aliases "$alias" "$namespace" "${keymap_entries[@]}"
	fi
}

function keymap_show {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_size=$1; shift
	local keymap_entries=("${@:1:$keymap_size}"); shift "$keymap_size"
	local description=$*

	# If `description` was not specified, print usage
	if [[ -z $description ]]; then
		keymap_print_help "$namespace" "$alias" "${keymap_entries[@]}"

	# Otherwise, filter mappings by `description`
	else
		keymap_filter_entries "$namespace" "$description"
	fi
}

#
# Helpers
#

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

function keymap_filter_entries {
	local namespace=$1; shift
	local description=$*

	# Find keymap entries with matching description
	local entries=("${(P)$(echo "$namespace" | upcase)[@]}")
	local entries_matched=()

	setopt nocasematch
	for entry in "${entries[@]}"; do
		if [[ $entry =~ $description ]]; then
			entries_matched+=("$entry")
		fi
	done
	unsetopt nocasematch

	# Print keymap entries matched
	echo
	if [[ -z ${entries_matched[*]} ]]; then
		red_bar "\`$description\` does not match any description"
	else
		local is_zsh_keymap; keymap_has_dot_alias "${entries_matched[@]}" && is_zsh_keymap=1
		local max_command_size; max_command_size=$(keymap_get_max_command_size "${entries_matched[@]}")

		for entry in "${entries_matched[@]}"; do
			keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
		done
	fi
}

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
	local keymap_entries=("$@")

	local last_entry
	local has_disjoint_dups
	declare -A seen

	for entry in "${keymap_entries[@]}"; do
		# Get the first token while igonring any leading "(|)? " pattern
		# Note: This is inlined and repeated b/c calling a function in a loop is slow
		[[ $entry == "$KEYMAP_PIPE_PATTERN"* ]] && entry="${entry#\(\|\)\? }"
		[[ $entry == *\ * ]] && first_token=${${(z)entry}[1]} || first_token=$entry

		# If it is the same as the last entry, allow it
		if [[ $first_token == "$last_entry" ]]; then
			continue

		# Otherwise, remember it to allow dupe in the next entry
		else
			last_entry=$first_token
		fi

		# If we have not seen an entry, remember it
		if [[ -z ${seen[$first_token]} ]]; then
			seen[$first_token]=$entry

		# Otherwise, report on disjoint dups
		else
			echo
			red_bar "\`$namespace\` has duplicate \`$first_token\` entries"
			has_disjoint_dups=1
		fi
	done

	[[ -n $has_disjoint_dups ]] && return 0 || return 1
}

function keymap_has_dot_alias {
	local keymap_entries=("$@")

	for entry in "${keymap_entries[@]}"; do
		# shellcheck disable=SC2076
		[[ $entry =~ ".+\\$KEYMAP_DOT.+ # .+" ]] && return 0
	done

	return 1
}

function keymap_set_dot_aliases {
	local alias=$1; shift
	local namespace=$1; shift
	local keymap_entries=("$@")

	local first_token
	local key
	declare -A seen

	for entry in "${keymap_entries[@]}"; do
		# Get the first token while igonring any leading "(|)? " pattern
		# Note: This is inlined and repeated b/c calling a function in a loop is slow
		[[ $entry == "$KEYMAP_PIPE_PATTERN"* ]] && entry="${entry#\(\|\)\? }"
		[[ $entry == *\ * ]] && first_token=${${(z)entry}[1]} || first_token=$entry

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

	echo
	echo -n 'Keymap: '
	cyan_fg "$namespace.zsh"

	keymap_print_map "$namespace" "${keymap_entries[@]}"

	local is_zsh_keymap; keymap_has_dot_alias "${keymap_entries[@]}" && is_zsh_keymap=1
	local max_command_size
	local keymap_usage=()

	# If it's the `ALL_NAMESPACE` or a non-zsh keymap, skip printing command line usage
	if [[ $namespace == "$ALL_NAMESPACE" || $is_zsh_keymap -ne 1 ]]; then
		max_command_size=$(keymap_get_max_command_size "${keymap_entries[@]}")
	else
		# Interpolate `alias` into `KEYMAP_USAGE`
		for entry in "${KEYMAP_USAGE[@]}"; do
			keymap_usage+=("${entry/$KEYMAP_ALIAS/$alias}")
		done

		max_command_size=$(keymap_get_max_command_size "${keymap_usage[@]}" "${keymap_entries[@]}")

		echo
		echo Keymap Usage
		echo

		for entry in "${keymap_usage[@]}"; do
			keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
		done

		keymap_annotate_the_dot "$alias" "$max_command_size"
	fi

	echo
	[[ $namespace == "$ALL_NAMESPACE" ]] && echo All Namespaces || echo Keymap List
	echo

	# `ALL_NAMESPACE` is an zsh keymap even though it does not have any dot aliases
	[[ $namespace == "$ALL_NAMESPACE" ]] && is_zsh_keymap=1

	for entry in "${keymap_entries[@]}"; do
		keymap_print_entry "$entry" "$is_zsh_keymap" "$max_command_size"
	done
}

# Zsh keymap keys should avoid these chars
# - `'` b/c it begins a new quote in zsh
# - `,` b/c it breaks IntelliJ's error checking
# - `.` b/c it's already used as `KEYMAP_DOT`
# - `;` b/c it begins a new command in zsh
# - `[` b/c it accesses hash key in zsh
# - `/` b/c it navigates path in zsh
# - `=` b/c it begins an assignment in zsh
# - `\` b/c it begins a new line in zsh
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

		# Get the first token while igonring any leading "(|)? " pattern
		# Note: This is inlined and repeated b/c calling a function in a loop is slow
		[[ $entry == "$KEYMAP_PIPE_PATTERN"* ]] && entry="${entry#\(\|\)\? }"
		[[ $entry == *\ * ]] && first_token=${${(z)entry}[1]} || first_token=$entry

		# Check `KEYMAP_DASH` before `KEYMAP_DOT` to account for keyboard shortcuts like `cmd-.`
		if [[ $first_token == *$KEYMAP_DASH* ]]; then
			key_initial=${first_token: -1}
		elif [[ $first_token == *$KEYMAP_DOT* ]]; then
			key_initial=${${first_token#*$KEYMAP_DOT}:0:1}
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
	# - If a key maps to multiple mapping functions, print with `()`
	# - If a key maps to one mapping function, print with `<>`
	# - If a key is unused, print in gray
	local row_input
	local row_output
	for i in {1..4}; do
		# shellcheck disable=SC2034 # Use via `${(P)row_input}`
		row_input=KEYMAP_PRINT_ROW_${i}
		row_output+="\n"

		for char in ${(P)row_input}; do
			escaped_initial="$KEYMAP_ESCAPE$char"

			# The `\` char doesn't work without an extra layer of escaping
			[[ $char == "$KEYMAP_ESCAPE" ]] && escaped_initial="$KEYMAP_ESCAPE\\"

			if [[ -z ${keymap_initials["$escaped_initial"]} ]]; then
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
	gray_fg '  `<>` key initials have one mapping'
	gray_fg '  `()` key initials have multiple mappings'

	# Notes on `<>, (), {}, []` usage
	# - `<>` is used to enclose keymap variables, e.g `<command>`
	#   - Also used to indicate key initials with one mapping
	# - `()` is used to enclose keymap literals, e.g `(i,iu,ir,im,e)`
	#   - Also used to indicate key initials with mulitple mappings
	#   - Also used in keymap descriptions to enclose clarifications
	# - `{}` is used to enclose keyboard keys, e.g `{esc}`
	#   - Cannot reuse `<>` b/c `"${${(z)...}[1]}"` splits on `<`
	#   - Cannot reuse `()` b/c "(`{F5}`)" looks better than "(`(F5)`)"
	# - `[]` cannot be used b/c `[` and `]` are keyboard keys in the keymap
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
	[[ $is_zsh_keymap -ne 1 ]] && prompt='  '

	# If command is a non-zsh keymap that contains `\` escape char, do not print it
	command=${command/-\\/-}

	# Print with color
	if [[ -n $command || -n $comment ]]; then
		printf "%s%-*s %s\n" "$prompt" "$command_size" "$command" "$(gray_fg "$comment")"

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
	local keymap_entries=("$@")

	local max_command_size=0
	local command_size

	for entry in "${keymap_entries[@]}"; do
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
	printf "%-*s%s%-*s %s\n" \
		$(($(echo -n "$KEYMAP_PROMPT" | bw | wc -c) + ${#alias})) \
		'' \
		"$(gray_fg "$KEYMAP_DOT_POINTER")" \
		"$((command_size - ${#alias} - ${#KEYMAP_DOT_POINTER}))" \
		'' \
		"$(gray_fg "# The \`$KEYMAP_DOT\` is only for documentation")"
	printf "%-*s%-*s %s\n" \
		$(($(echo -n "$KEYMAP_PROMPT" | bw | wc -c) + ${#alias})) \
		'' \
		"$((command_size - ${#alias}))" \
		'' \
		"$(gray_fg "# Omit it when invoking a mapping")"
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

# Includes custom zsh and non-zsh keymaps
# But excludes default keyboard shortcuts
function keymap_files {
	ls "$ZSHRC_DIR"/**/*_keymap.zsh | bw | grep --invert-match _tests
	# Note: ^ `ls "$ZSHRC_DIR"/**!(_tests)/*_keymap.zsh` works in the current shell
	# But it isn't working in the tests subshell even with `setopt EXTENDED_GLOB`
}
