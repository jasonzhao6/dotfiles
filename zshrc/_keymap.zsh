# A keymap is a namespaced collection of shortcuts following this format:
#
#   [namespace] [key] [args]... # Optional comment
#
# Executing `[namespace]` prints the list of shortcuts in that namespace
# Executing `[namespace] [key]` invokes the `[namespace]_[key]` function
#

function keymap_help {
	# Reconstruct arrays from these args: `usage_size, usage[]..., keymap[]...`
	local usage_size=$1; shift
	local usage=("${@:1:$usage_size}")
	local keymap=("${@:$usage_size + 1}")

	# Get the max command size used to align comments across commands, e.g
	#   ```
	#   $ <command>      # comment
	#   $ <long command> # another comment
	#   ```
	local max_command_size; max_command_size=$(keymap_get_max_command_size "$@")

	echo
	echo 'Usage'
	echo

	for entry in "${usage[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done

	echo
	echo 'Keymaps'
	echo

	for entry in "${keymap[@]}"; do
		keymap_print_entry "$entry" "$max_command_size"
	done
}

KEYMAP_DUPE_ERROR_BAR="$(red_bg '  Error: Cannot have duplicate keys  ')"

function keymap_invoke {
	local keymap_size=$1; shift
	local keymap=("${@:1:$keymap_size}"); shift "$keymap_size"
	local namespace=$1; shift
	local key=$1; [[ -n $key ]] && shift || return

	local dupes; dupes=$(keymap_check_for_dupes "${keymap[@]}")
	[[ -n $dupes ]] && echo "$dupes\n$KEYMAP_DUPE_ERROR_BAR" && return

	for entry in "${keymap[@]}"; do
		if [[ $entry == "$namespace $key "* ]]; then
			"${namespace}_${key}" "$@"
		fi
	done
}

#
# Helpers
#

function keymap_get_max_command_size {
	local max_command_size=0

	for entry in "$@"; do
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

	printf "%s %-*s %s\n" "$KEYMAP_PROMPT" "$command_size" "$command" "$(gray_fg "$comment")"
}

function keymap_check_for_dupes {
	typeset -A seen

	for entry in "$@"; do
		first_two_words="${(j: :)${(z)entry}[1,2]}"

		if [[ -z ${seen[$first_two_words]} ]]; then
			seen[$first_two_words]=$entry
		else
			echo "${seen[$first_two_words]}"
			echo "$entry"
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
