#
# Utils
#

function caller {
	# shellcheck disable=SC2154
	echo "${funcstack[3]}"
} # TODO add test

function callee {
	echo "${funcstack[2]}"
} # TODO add test

function echo_eval {
	local command=$*

	echo "$command" >&2
	eval "$command"
}

function ellipsize {
	local string=$*

	if [[ ${#1} -gt $COLUMNS ]]; then
		echo -n "${1:0:$((COLUMNS - 4))} \e[30m\e[47m...\e[0m"
	else
		echo "$string"
	fi
}

function epoch {
	local decimals=$1

	if [[ -z $decimals || $decimals -le 0 ]]; then
		gdate +%s
	else
		gdate +%s.%"${decimals}"N
	fi
} # TODO add test

function has_internet {
	curl -s --max-time 1 http://www.google.com &> /dev/null
}

function index_of {
	local string=$1
	local substring=$2

	awk \
		-v str1="$(echo "$string" | bw)" \
		-v str2="$(echo "$substring" | bw)" \
		'BEGIN { print index(str1, str2) }'
}

function next_ascii {
	local char=$*

	# shellcheck disable=SC2059
	printf "%b" "$(printf "\\$(printf "%o" $(($(printf "%d" "'$char") + 1)))")"
}

function paste_when_empty {
	local string=$*

	echo "${string:-$(pbpaste)}"
}

function prev_command {
	fc -ln -1
}

function zprod_start {
	zmodload zsh/zprof
}

function zprod_finish {
	zprof
}

#
# `|` Utils after strings
#

function bw {
	sed -E 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'
}

function compact {
	sed '/^$/d'
}

function contain {
	local substring=$*

	if [[ -z $substring ]]; then
		cat
	else
		# Use `pgrep` to filter, then use `grep` to color
		pgrep --ignore-case --only-matching ".*$substring.*" | bw | grep "$substring"
	fi
}

function downcase {
	tr '[:upper:]' '[:lower:]'
} # TODO add test

function extract_urls {
	pgrep --only-matching '\b(?:https?:\/\/)(?:www\.)?[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,6}(?:\/[^\s?#]*)?(?:\?[^\s#]*)?(?:#[^\s]*)?\b'
}

function hex {
	hexdump -C
}

function strip {
	strip_left | strip_right
}

function strip_left {
	sed 's/^[[:space:]]*//'
}

function strip_right {
	sed 's/[[:space:]]*$//'
}

function trim {
	local left=$1
	local right=$2

	bw |
		# Trim left side
		cut -c $((left + 1))- |
		# Trim right side
		{ [[ -z $right ]] && cat || rev | cut -c $((right + 1))- | rev; }
}

#
# `|` Utils after columns
#

function insert_hash {
	awk '
		NF >= 2 {
			col_2_index = index($0, $2)
			col_1 = substr($0, 1, col_2_index - 1)
			col_rest = substr($0, col_2_index)
			printf "%s# %s\n", col_1, col_rest
		}
		NF < 2 {
			print
		}
	'
}

function size_of {
	local column=$1

	awk '
		{
			if (length($'"${column:-0}"') > max_len) {
				max_len = length($'"${column:-0}"')
			}
		}
		END {
			print max_len
		}
	'
}

#
# `|` Utils after json
#

function keys {
	jq keys | trim_list | args_keymap_s
}

function trim_list {
	sed -e 's/^\[//' -e 's/^]//' -e 's/^ *"//' -e 's/",\{0,1\}$//' | compact
}
