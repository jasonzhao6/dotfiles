### Util
# singles (they save into `args`)
function d { [[ -n "$1" ]] && { D=${${${@}#*://}%%/*}; [[ -z $ZSHRC_UNDER_TEST ]] && dig +short $D | as || printf "test output for\n%s" "$D" | as; }; }
function f { [[ -n "$1" ]] && f_pre "$@" | sort | as; }
function l { ls -l | awk '{print $9}' | as "$@"; } # Not taking search pattern b/c folder matches break column alignment
function ll { ls -lA | awk '{print $9}' | egrep '^(\e\[3[0-9]m)?\.' | bw | as "$@"; } # Show only hidden files
# doubles (they do not save into `args`)
function bb { pmset sleepnow; }
function cc { eval "$(prev_command)" | bw | ruby -e 'puts STDIN.read.strip' | pbcopy; }
function dd { mkdir -p "$DD_DUMP_DIR"; dd_is_terminal_output && { DD=$(dd_dump_file); pbpaste > "$DD"; dd_taint_pasteboard; dd_clear_terminal; } || dd_clear_terminal; }
function ddd { mkdir -p "$DD_DUMP_DIR"; cd "$DD_DUMP_DIR" || return; }
function ddc { rm -rf "$DD_DUMP_DIR"; }
function ee { for i in $(seq "$1" "$2"); do echo ${${@:3}//~~/$i}; done; }
function eee { for i in $(seq "$1" "$2"); do echo; echo_eval ${${@:3}//~~/$i}; done; }
function ff { caffeinate; }
function hh { diff --side-by-side --suppress-common-lines "$1" "$2"; }
function ii { open -na 'IntelliJ IDEA CE.app' --args "${@:-.}"; }
function mm { mate "${@:-.}"; }
function oo { oo_open "$@"; }
function pp { ruby ~/gh/jasonzhao6/sql_formatter.rb/run.rb "$@"; }
function tt { ~/gh/tt/tt.rb "$@"; }
function uu { diff --unified "$1" "$2"; }
function xx { printf "bind '\"\\\e[A\": history-search-backward'\nbind '\"\\\e[B\": history-search-forward'" | pbcopy; }
function yy { YY=$(prev_command); echo -n "$YY" | pbcopy; }
# one-offs
function bif { brew install --formula "$@"; }
function flush { sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder; }
function jcurl { curl --silent "$1" | jq | { [[ -z "$2" ]] && cat || grep -A"${3:-0}" -B"${3:-0}" "$2"; }; }
function ren { for file in *"$1"*; do mv "$file" "${file//$1/$2}"; done; }
# helpers
function caller { echo "${funcstack[3]}"; }
function callee { echo "${funcstack[2]}"; }
function echo_eval { echo "$@" >&2; eval "$@"; }
function ellipsize { [[ ${#1} -gt $COLUMNS ]] && echo -n "${1:0:$((COLUMNS - 4))} \e[30m\e[47m...\e[0m" || echo "$@"; }
function has_internet { curl -s --max-time 1 http://www.google.com &> /dev/null; }
function index_of { awk -v str1="$(echo "$1" | bw)" -v str2="$(echo "$2" | bw)" 'BEGIN { print index(str1, str2) }'; }
# shellcheck disable=SC2059
function next_ascii { printf "%b" "$(printf "\\$(printf "%o" $(($(printf "%d" "'$*") + 1)))")"; }
function paste_when_empty { echo "${@:-$(pbpaste)}"; }
function prev_command { fc -ln -1; }
# helper for `f`
function f_pre {
	[[ "$1" == gh ]] && gh repo list "$(org)" --no-archived --limit 1000 --json name | jq -r '.[].name'
	[[ "$1" == tf ]] && find ~+ -name main.tf | grep --invert-match '\.terraform' | sed "s|$HOME|~|g" | trim 0 8
}
# helpers for `dd`
function dd_init { DD_CLEAR_TERMINAL=1; DD_DUMP_DIR="$HOME/.zshrc.terminal-dump.d"; }; dd_init
function dd_is_terminal_output { [[ $(pbpaste | compact | strip | sed -n '$p') == \$* ]]; }
function dd_dump_file { echo "$DD_DUMP_DIR/$(gdate +'%Y-%m-%d_%H.%M.%S.%6N').txt"; }
function dd_taint_pasteboard { printf "$(pbpaste)\n\n(Dumped to '%s')" "$DD" | pbcopy; }
function dd_clear_terminal { [[ $DD_CLEAR_TERMINAL -eq 1 ]] && clear; }
# helper for `oo`
function oo_open {
	[[ -z $1 ]] && open . && return
	[[ -d $1 ]] && open "$1" && return
	[[ -f $1 ]] && open "$1" && return

	echo "$@" | extract_urls | bw | while IFS= read -r url; do open "$url"; done
}
# | after strings
function bw { sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'; }
function compact { sed '/^$/d'; }
function contain { pgrep --only-matching ".*$*.*" | bw; }
function extract_urls { pgrep --only-matching '\b(?:https?:\/\/)(?:www\.)?[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,6}(?:\/[^\s?#]*)?(?:\?[^\s#]*)?(?:#[^\s]*)?\b'; }
function hex { hexdump -C; }
function strip { strip_left | strip_right; }
function strip_left { sed 's/^[[:space:]]*//'; }
function strip_right { sed 's/[[:space:]]*$//'; }
function trim { bw | cut -c $(($1 + 1))- | { [[ -z $2 ]] && cat || rev | cut -c $(($2 + 1))- | rev; }; }
# | after columns
function insert_hash { awk 'NF >= 2 {col_2_index = index($0, $2); col_1 = substr($0, 1, col_2_index - 1); col_rest = substr($0, col_2_index); printf "%s# %s\n", col_1, col_rest} NF < 2 {print}'; }
function size_of { awk "{if (length(\$${1:-0}) > max_len) max_len = length(\$${1:-0})} END {print max_len}"; }
# | after json
function keys { jq keys | trim_list | as; }
function trim_list { sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | compact; }
