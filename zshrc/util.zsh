### Util
# singles (they save into `args`)


function f {
	[[ -n "$1" ]] && f_pre "$@" | sort | args_keymap_s
}

function dd {
	mkdir -p "$DD_DUMP_DIR"; dd_is_terminal_output && { DD=$(dd_dump_file); pbpaste > "$DD"; dd_taint_pasteboard; dd_clear_terminal; } || dd_clear_terminal
}

function ddd {
	mkdir -p "$DD_DUMP_DIR"; cd "$DD_DUMP_DIR" || return
}

function ddc {
	rm -rf "$DD_DUMP_DIR"
}

function pp {
	ruby ~/gh/jasonzhao6/sql_formatter.rb/run.rb "$@"
}

function jcurl {
	curl --silent "$1" | jq | { [[ -z "$2" ]] && cat || grep -A"${3:-0}" -B"${3:-0}" "$2"; }
}

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
