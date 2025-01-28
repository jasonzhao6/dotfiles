function init {
	passes=0
	total=0
	failed=''
	debug=''
}

function assert {
	local output=$1
	local expected=$2

	# shellcheck disable=SC2154
	[[ $output == "$expected" ]] && pass || fail "'${funcstack[2]}'" "$output" "$expected"
}

function run_with_filter {
	local test_name=$1

	[[ -z $ZSHRC_TESTS_NAME_FILTER || $test_name == *$ZSHRC_TESTS_NAME_FILTER* ]] && $test_name
}

function print_summary {
	local message=$1

	echo
	echo "($passes/$total $message)"
	[[ $passes -ne $total ]] && echo "$failed" "$debug"
}

#
# Helpers
#

function find_test_files {
	ls "$ZSHRC_DIR"/_tests/**/test_*.zsh | bw | sort --random-sort
}

function pass {
	((passes++))
	((total++))
	echo -n .
}

function fail {
	local name=$1
	local output=$2
	local expected=$3

	failed+="\n$(red_bg fail): $name"
	((total++))
	echo -n f

	if [[ -n $output || -n $expected ]]; then
		debug+="\n\n$(red_bg debug): $name\n"
		debug+=$(diff -u <(echo "$expected") <(echo "$output") | sed '/--- /d; /+++ /d; /@@ /d')
	fi
}

# Emulate `grep` color codes
function grep_color { echo "\e[1;32m\e[K$*\e[m\e[K"; }
function pgrep_color { echo "\e[1;32m$*\e[00m"; }
