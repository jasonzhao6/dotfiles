#
# Lis[t]
#

function t {
	local type_prefix=$1

	if [[ -z $type_prefix ]]; then
		cat <<-eof

			Usage:

			  t <type> <arguments>*
			  t <type prefix> <arguments>*

			Types:

			  # t asg <asg name prefix>
			  # t ec2 <ec2 name prefix>
			  t opal
		eof
	else
		[[ 'opal' == $type_prefix* ]] && t_opal
	fi
}

function t_opal {
	print -l "${T_OPAL[@]}" | sort -k2 | column -t | ss
}
