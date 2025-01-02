#
# Lis[t]
#

function t {
	local type_prefix=$1

	if [[ -z $type_prefix ]]; then
		cat <<-eof

			Usage:

			  t
			  t <type> <arguments>?
			  t <type prefix> <arguments>?

			Types:
			  $([[ -n $T_UNDER_TEST ]] && echo -n 't test <arg1> <arg2>')

			  # t asg <asg name prefix>
			  # t ec2 <ec2 name prefix>
			  t opal
		eof
	else
		[[ 'test' == $type_prefix* ]] && t-test "${@:2}"

		[[ 'opal' == $type_prefix* ]] && t-opal
	fi
}

function t-test {
	echo "arg1: $1"
	echo "arg2: $2"
}

T_OPAL=(
	'non-secret-placeholder1 url1'
	'non-secret-placeholder2 url2'
	'non-secret-placeholder3 url3'
)

function t-opal {
	print -l "${T_OPAL[@]}" | sort | column -t | ss
}
