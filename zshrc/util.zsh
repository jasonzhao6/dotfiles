### Util
# singles (they save into `args`)


function f {
	[[ -n "$1" ]] && f_pre "$@" | sort | args_keymap_s
}

function pp {
	ruby ~/gh/jasonzhao6/sql_formatter.rb/run.rb "$@"
}

# helper for `f`
function f_pre {
	[[ "$1" == gh ]] && gh repo list "$(org)" --no-archived --limit 1000 --json name | jq -r '.[].name'
	[[ "$1" == tf ]] && find ~+ -name main.tf | grep --invert-match '\.terraform' | sed "s|$HOME|~|g" | trim 0 8
}
# helpers for `dd`
