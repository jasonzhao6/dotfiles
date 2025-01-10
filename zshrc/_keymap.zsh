KEYMAP_PROMPT=$(yellow_fg '  $')
KEYMAP_ALIAS='_PLACEHOLDER_'
KEYMAP_DOT='·'
KEYMAP_DOT_POINTER='^'

KEYMAP_USAGE=(
	"$KEYMAP_ALIAS # Show this help"
	''
	"$KEYMAP_ALIAS$KEYMAP_DOT<key> # Invoke <key>"
	"$KEYMAP_ALIAS$KEYMAP_DOT<key> <args>* # Invoke <key> with multiple <args>"
)

function keymap_init {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_entries=("$@")

	# If `keymap_entries` contains disjoint duplicate `key`s, abort and print error message
	keymap_check_for_disjoint_dupes "${keymap_entries[@]}"
	[[ $? -eq 1 ]] && return

	# Alias the `<namespace>` function to `<alias>`
	keymap_alias "$alias" "$namespace"

	# Alias the `<namespace>_<key>` functions to `<alias><key>`
	local alias_dot_key
	local entry_key
	for entry in "${keymap_entries[@]}"; do
		[[ -z $entry ]] && continue # Skip empty lines

		alias_dot_key=$(echo "$entry" | awk '{print $1}')
		[[ $alias_dot_key != *$KEYMAP_DOT* ]] && continue # Skip keyless entries

		entry_key=$(echo "$alias_dot_key" | trim 2)
		keymap_alias "$alias$entry_key" "${namespace}_$entry_key"
	done
}

# Exit codes and corresponding prints
# - 1: Print error message about non-consecutive duplicate `key`s
# - 2: Print usage since `key` was not specified
# - 3: Print usage since `key` was not found
# - 0: Print output from invoking `key`
function keymap_invoke {
	local namespace=$1; shift
	local alias=$1; shift
	local keymap_size=$1; shift
	local keymap_entries=("${@:1:$keymap_size}"); shift "$keymap_size"
	local key=$1; [[ -n $key ]] && shift
	local args=("$@")

	# If a `key` was not specified, abort and print usage
	[[ -z $key ]] && keymap_help "$namespace" "$alias" "${keymap_entries[@]}" && return 2

	# Look for the specified `key`
	local found
	for entry in "${keymap_entries[@]}"; do
		[[ $entry == "$alias$KEYMAP_DOT$key"* ]] && found=1 && break
	done

	# If not found, print usage
	if [[ -z $found ]]; then
		keymap_help "$namespace" "$alias" "${keymap_entries[@]}"
		return 3

	# If found, invoke it with the specified `args`
	else
		"${namespace}_${key}" "${args[@]}"
	fi
}

#
# Helpers
#

# ```
# o·c       # Open the latest commit
# o·c <sha> # Open the specified commit  <--  Joint duplicate, likely intentional
#
# o·a       # Do something
# o·c       # Do something else          <--  Disjoint duplicate, likely unintentional
# ```
function keymap_check_for_disjoint_dupes {
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
			red_bar "\`$alias_dot_key\` has duplicate entries"
			has_disjoint_dupes=1
		fi
	done

	[[ -n $has_disjoint_dupes ]] && return 1 || return 0
}

function keymap_alias {
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
	#   $ <command>      # comment
	#   $ <long command> # another comment
	#   ```
	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${keymap_usage[@]}" "${keymap_entries[@]}")

	echo
	echo 'Name'
	echo

	yellow_fg "  $namespace"

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

	for entry in "${entries[@]}"; do
		local command_size="${#entry% \#*}"
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
		"$(gray_fg "# The $KEYMAP_DOT represents an optional space")"
}

function keymap_print_entry {
	local entry=$1
	local command_size=$2

	local command="${entry% \#*}"
	local comment; [[ $entry = *\#* ]] && comment="# ${entry#*\# }"

	# Print with color
	if [[ -n $command ]]; then
		printf "%s %-*s %s\n" "$KEYMAP_PROMPT" "$command_size" "$command" "$(gray_fg "$comment")"

	# Allow empty line as separators between different sections of a keymap
	else
		echo
	fi
}

### Keymap annotations
#  ::  -->  subsequent command
#  |   -->  alternative command
#  ~   -->  repeatable command
#  ()  -->  order of precedence
#  ,   -->  argument separator
#  ?   -->  optional command / argument
#  #   -->  number argument
#  _   -->  letter argument
#  *   -->  arbitrary argument
#  ~~  -->  to be substituted
#  ""  -->  quotes recommended
#  %+v -->  `cmd + v` to paste

### Git keymap
# [] means defined in this file
# <> means already taken, e.g `go`
# [1]  2   3   4   5  |  6   7   8   9  [0]   <--   g1|g0   gt|gtv|gta|gtr   gb::#,(g|gbb|gbd)   gg|(gn,*)
#             [p]  y  | [f] [g] [c] [r] [l]   <--   gd|gq   ge|gm|gw|gv|gi   gp|gf|gP   gs,*?::(ga,#?)|gl|gc
# [a] <o> [e] [u] [i] | [d] <h> [t] [n] [s]   <--   gx,*::gxx,(u|m|#)?::(gxa|gxc)?   (gu|gz|guz),#?
#     [q]  j   k  [x] | [b] [m] [w] [v] [z]   <--   (gr|gr-),*?::s::#,sha

### Kubectl keymap
#  1   2   3   4   5  |  6   7   8   9   0
#             [p] [y] |  f  [g] [c] [r] [l]
#  a   o  [e]  u   i  | [d]  h   t   n  [s]
#     [q] [j] [k] [x] | [b]  m   w   v   z

### Terraform keymap
# [] means defined in this file
# {} means defined in secrets file
# [1]  2   3   4   5  |  6   7   8   9  [0]   <--   tf1|tf0   tfi|tfiu|tfir|tfim
#             [p]  y  | [f] [g] [c] [r] [l]   <--   tfi::(tfp|tfl|tfo|tfn|tfv),(e|i|iu|ir|im)?::tf?
# [a] [o] {e} [u] [i] | [d]  h  [t] [n] [s]   <--   tfp::tfa|tfd|tfg|(tfz,*)   tfl::(tfs|tft|tfu|tfm|tfr),*
#      q   j   k   x  |  b  [m]  w  [v] [z]   <--   tfc|tfcc   f,tf::(a,*)?::#,cd

### Singles keymap
# () means defined for `args`
# [] means defined in this file
# {} means defined in secrets file
# (1) (2) (3) (4) (5) | (6) (7) (8) (9) (0)   <--   s|ss|v|vv::a|n   a,*?,-*?::~?::#   (n|nn),_?::#
#             (p) (y) | [f] [g] (c) (r) [l]   <--   #|aa|each|all|map,*,~~?   e,#,#,*,~~?   #?,c::%+v
# (a) [o] (e) (u) (i) | [d] [h] [t] (n) (s)   <--   y::p   u|r::~?   i::i,#   d|f|h|w|kk|l|ll::a
#     {q} {j} [k]  x  |  b   m  [w] (v) [z]   <--   z|zz

### Doubles keymap
# () means defined for `args`
# [] means defined in this file
# {} means defined in secrets file
# (1)  2   3   4   5  |  6   7   8   9   0
#             [p] [y] | [f] [g] [c]  r  [l]   <--   pp,""?,*?::cc   yy|cc|xx::%+v   ff|bb   l|ll::a
# (a) [o] [e] [u] [i] | [d] [h] [t] (n) (s)   <--   oo|ii|mm   ee,#,#,*,~~::eee   uu|hh   dd::ddd|ddc
#     {q} {j} [k] [x] | [b] [m]  w  (v) [z]   <--   qq|q2::q   jj::#,j
