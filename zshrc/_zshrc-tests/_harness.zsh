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

	failed+="\nfail: $name"
	((total++))
	echo -n f

	debug+="\n\ndebug: $name\n"
	debug+=$(diff -u <(echo $expected) <(echo $output) | sed '/--- /d; /+++ /d; /@@ /d')
}

function assert {
	local output=$1
	local expected=$2

	[[ $output == $expected ]] && pass || fail "'$funcstack[2]'"
}

function run-with-filter {
	[[ -z $test_filter || $(index-of $@ $test_filter) -ne 0 ]] && $@
}

function print-summary {
	local message=$1

	echo "\n($passes/$total $message)"
	[[ $passes -ne $total ]] && echo $failed $debug
}
