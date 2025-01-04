# shellcheck disable=SC2015 # Allow `A && B || C`

function init {
	passes=0
	total=0
	failed=''
	debug=''
}

function pass {
	((passes++))
	((total++))
	echo -n .
}

function fail {
	local name=$1

	failed+="\n$(red_bg fail): $name"
	((total++))
	echo -n f

	debug+="\n\n$(red_bg debug): $name\n"
	debug+=$(diff -u <(echo "$expected") <(echo "$output") | sed '/--- /d; /+++ /d; /@@ /d')
}

function assert {
	local output=$1
	local expected=$2

	# shellcheck disable=SC2154
	[[ $output == "$expected" ]] && pass || fail "'${funcstack[2]}'"
}

function run_with_filter {
	[[ -z $test_filter || $(index_of "$@" "$test_filter") -ne 0 ]] && "$@"
}

function print_summary {
	local message=$1

	echo
	echo "($passes/$total $message)"
	[[ $passes -ne $total ]] && echo "$failed" "$debug"
}
