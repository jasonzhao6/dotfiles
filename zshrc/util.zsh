### Util
# singles (they save into `args`)


function f {
	[[ -n "$1" ]] && f_pre "$@" | sort | args_keymap_s
}

# helper for `f`
function f_pre {


	find ~+ -name main.tf | grep --invert-match '\.terraform' | sed "s|$HOME|~|g" | trim 0 8
}
# helpers for `dd`
