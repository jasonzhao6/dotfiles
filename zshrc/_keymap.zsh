# `_` is a placeholder for a single-letter namespace.
# It is to be substituted with the passed in namespace when printing.
# It's important to keep it the same length as the longest namespace for
# the purpose of aligning the comments in the `keymap_help` function.
KEYMAP_USAGE=(
  '_ # Show this help'
	'_ <key> <args>* # Invoke a key mapping'
)

KEYMAP_DUPE_ERROR_BAR="$(red_bar 'Error: Cannot have duplicate keys')"

# Possible outcomes:
# - Print error with exit code 1
# - Print usage with exit code 1
# - Print empty output with exit code 1
# - Print non-empty output with exit code 0
function keymap {
	local namespace=$1; shift
	local keymap_size=$1; shift
	local keymap=("${@:1:$keymap_size}"); shift "$keymap_size"
	local key=$1; [[ -n $key ]] && shift
	local args=("$@")

	# If keymap contains duplicate `key`s, abort and print error
	local dupes; dupes=$(keymap_check_for_dupes "${keymap[@]}")
	[[ -n $dupes ]] && printf "%s\n\n%s" "$dupes" "$KEYMAP_DUPE_ERROR_BAR" && return 1

	# If no key is passed in, print usage
	[[ -z $key ]] && { keymap_help "$namespace" "${keymap[@]}"; return 1; }

	# Look for the key mapping and invoke it; if not found, print usage
	local found
	local output

	for entry in "${keymap[@]}"; do
		if [[ $entry == "$namespace $key "* ]]; then
			found=1
			output=$("${namespace}_${key}" "${args[@]}")
		fi
	done

	[[ -z $found ]] && { keymap_help "$namespace" "${keymap[@]}"; return 1; }
	[[ -n $output ]] && echo "$output" || { echo '(There was no output)'; return 1; }
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

	if [[ -n $command ]]; then
		printf "%s %-*s %s\n" "$KEYMAP_PROMPT" "$command_size" "$command" "$(gray_fg "$comment")"
	else
		echo
	fi
}

function keymap_check_for_dupes {
	local entries=("$@")

	typeset -A seen

	for entry in "${entries[@]}"; do
		first_two_words="${(j: :)${(z)entry}[1,2]}"

		if [[ -z ${seen[$first_two_words]} ]]; then
			seen[$first_two_words]=$entry
		else
			echo
			echo "> ${seen[$first_two_words]}"
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
