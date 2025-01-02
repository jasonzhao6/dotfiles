#
# Lis[t]
#

function t {
	local type_prefix=$1; shift

	if [[ -z $type_prefix ]]; then
		cat <<-eof

			Usage:

			  t <type_prefix> <arguments...>
			  t <type_prefix prefix> <arguments...> # Use the first type_prefix matching prefix

			Available types:

			  # t asg <asg name prefix>
			  # t ec2 <ec2 name prefix>
			  t opal
		eof
	else
		[[ 'opal' == $type_prefix* ]] && t_opal
	fi
}

function t_opal {
	for k v in ${(kv)T_OPAL}; do
		echo $v $k
	done | sort -k2,2 | column -t | s
}
