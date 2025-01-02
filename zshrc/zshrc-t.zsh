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

			  # t asg <asg name prefix>
			  # t ec2 <ec2 name prefix>
			  t opal
		eof
	else
		[[ 'opal' == $type_prefix* ]] && t-opal
	fi
}

function t-opal {
	print -l "${T_OPAL[@]}" | sort | column -t | ss
}
