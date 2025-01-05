# TODO tests

function keymaps_help {
	local usage=()
	local keymaps=()
	local usage_size="${*[-1]}"

	# Reconstruct arrays from args: `usage[]..., keymaps[]..., usage_size`
	for ((i = 1; i < ${#@}; i++)); do
		[[ $i -le $usage_size ]] && usage+=("${*[$i]}")
		[[ $i -gt $usage_size ]] && keymaps+=("${*[$i]}")
	done

	# Get the max command size in order to align their comments
	local max_command_size
	max_command_size=$(keymaps_get_max_command_size "${@[1,-2]}")

	echo
	echo 'Usage'
	echo

	for line in "${usage[@]}"; do
		keymaps_print_command "$line" "$max_command_size"
	done

	echo
	echo 'Keymaps'
	echo

	for line in "${keymaps[@]}"; do
		keymaps_print_command "$line" "$max_command_size"
	done
}

function keymaps_get_max_command_size {
	local max_command_size=0

	for line in "$@"; do
		local command_size="${#line% \#*}"
		[[ $command_size -gt $max_command_size ]] && max_command_size=$command_size
	done

	echo "$max_command_size"
}

KEYMAPS_PROMPT=$(yellow_fg '  $')

function keymaps_print_command {
	local list_type=$1
	local command_size=$2

	local command="${list_type% \#*}"
	local comment; [[ $list_type = *#* ]] && comment="# ${list_type#*\# }"

	printf "%s %-*s %s\n" "$KEYMAPS_PROMPT" "$command_size" "$command" "$(gray_fg "$comment")"
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
