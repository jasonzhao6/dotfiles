#
# Lis[t]
#

function t {
	local type_prefix=$1

	if [[ -z $1 ]]; then
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
	fi
}

function to {
	for k v in ${(kv)T_OPAL}; do
		echo $v $k
	done | sort -k2,2 | column -t | s
}
