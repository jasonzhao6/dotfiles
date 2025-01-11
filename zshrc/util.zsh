### Util
# singles (they save into `args`)
function d { [[ -n "$1" ]] && { D=${${${@}#*://}%%/*}; [[ -z $ZSHRC_UNDER_TEST ]] && dig +short $D | args_keymap_s || printf "test output for\n%s" "$D" | args_keymap_s; }; }
function f { [[ -n "$1" ]] && f_pre "$@" | sort | args_keymap_s; }
function l { ls -l | awk '{print $9}' | args_keymap_s "$@"; } # Not taking search pattern b/c folder matches break column alignment
function ll { ls -lA | awk '{print $9}' | egrep '^(\e\[3[0-9]m)?\.' | bw | args_keymap_s "$@"; } # Show only hidden files
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

# | after json
function keys { jq keys | trim_list | args_keymap_s; }
function trim_list { sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | compact; }
