# `_` is a placeholder for a single-letter namespace.
# If namespace grows beyond single-letter, update here to match in order to
# keep the comments alignment logic in the `keymap_help` function working.
KEYMAP_USAGE=(
  '_ # Show this help'
	''
	'_·<key> # Invoke <key>'
	'_·<key> <args>* # Invoke <key> with multiple <args>'
)

KEYMAP_DOT='·'

KEYMAP_DUPE_ERROR_BAR="$(red_bar 'Error: Cannot have duplicate keys')"

# Exit codes and corresponding prints
# - 1: Print error message about non-consecutive duplicate `key`s
# - 2: Print usage since `key` was not specified
# - 3: Print usage since `key` was not found
# - 0: Print output from invoking `key`
function keymap {
	local namespace=$1; shift
	local keymap_size=$1; shift
	local keymap=("${@:1:$keymap_size}"); shift "$keymap_size"
	local key=$1; [[ -n $key ]] && shift
	local args=("$@")

	# If keymap contains disjoint duplicate `key`s, abort and print error message
	#   ```
	#   o·c       # Open the latest commit
	#   o·c <sha> # Open the specified commit  <--  Joint duplicate, likely intentional
	#
	#   o·a       # Do something
	#   o·c       # Do something else          <--  Disjoint duplicate, likely unintentional
	#   ```
	local dupes; dupes=$(keymap_check_for_disjoint_dupes "${keymap[@]}")
	[[ -n $dupes ]] && printf "%s\n\n%s" "$dupes" "$KEYMAP_DUPE_ERROR_BAR" && return 1

	# If a `key` was not specified, abort and print usage
	[[ -z $key ]] && keymap_help "$namespace" "${keymap[@]}" && return 2

	# Look for the specified `key`
	local found

	for entry in "${keymap[@]}"; do
		[[ $entry == "$namespace$KEYMAP_DOT$key"* ]] && found=1 && break
	done

	# If not found, print usage
	if [[ -z $found ]]; then
		keymap_help "$namespace" "${keymap[@]}"
		return 3

	# If found, invoke it with `args`
	else
		"${namespace}${key}" "${args[@]}"
	fi
}

#
# Helpers
#

function keymap_help {
	# Reconstruct arrays from these args: `usage_size, usage[]..., keymap[]...`
	local namespace=$1; shift
	local keymap=("$@")

	# Get the max command size in order to align comments across commands, e.g
	#   ```
	#   $ <command>      # comment
	#   $ <long command> # another comment
	#   ```
	local max_command_size
	max_command_size=$(keymap_get_max_command_size "${KEYMAP_USAGE[@]}" "${keymap[@]}")

	echo
	echo 'Usage'
	echo

	for entry in "${KEYMAP_USAGE[@]}"; do
		keymap_print_entry "${entry/_/$namespace}" "$max_command_size"
	done

	echo
	echo 'Keymap'
	echo

	for entry in "${keymap[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done

	echo
	gray_fg "     ^ The space between \`$namespace\` and <key> is optional."
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

KEYMAP_PROMPT=$(yellow_fg '  $')

function keymap_print_entry {
	local entry=$1
	local command_size=$2

	local command="${entry% \#*}"
	local comment; [[ $entry = *\#* ]] && comment="# ${entry#*\# }"

	# Print with color
	if [[ -n $command ]]; then
		printf "%s %-*s %s\n" "$KEYMAP_PROMPT" "$command_size" "$command" "$(gray_fg "$comment")"

	# Allow empty line as a separator between different sections of a keymap
	else
		echo
	fi
}

function keymap_check_for_disjoint_dupes {
	local entries=("$@")
	local last_entry

	typeset -A seen

	for entry in "${entries[@]}"; do
		namespace_dot_key="${(j: :)${(z)entry}[1,3]}"

		# If it is the same as the last entry, skip it
		if [[ $namespace_dot_key == "$last_entry" ]]; then
			continue

		# Otherwise, remember it for the next iteration
		else
			last_entry=$namespace_dot_key
		fi

		# If we have not see it, remember it
		if [[ -z ${seen[$namespace_dot_key]} ]]; then
			seen[$namespace_dot_key]=$entry

		# Otherwise, we found a pair of disjoint dupes
		else
			echo
			echo "> ${seen[$namespace_dot_key]}"
			echo "> $entry"
		fi
	done
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
