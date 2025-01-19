function ec2_args {
	local name="$1"

	aws ec2 describe-instances \
		--filters "$name" 'Name=instance-state-name, Values=running' \
		--query 'Reservations[].Instances[].[PrivateIpAddress, LaunchTime, Tags[?Key==`Name` || Key==`aws:autoscaling:groupName`].Value|[0]]' \
		--output text |
			sort --key=3 |
			sed 's/+00:00\t/Z  /g' |
			args_keymap_so
}

function ec2_get_id {
	if [[ "$1" =~ ^(i-)?[a-z0-9]{17}$ ]]; then
		[[ "$1" =~ ^i-.*$ ]] && echo "$1" || echo i-"$1"
	else
		[[ "$1" =~ ^[0-9\.]+$ ]] && ec2_ip_to_id "$1" || ec2_name_to_id "$1"
	fi
}

function ec2_ip_to_id {
	local ip=$1

	aws ec2 describe-instances \
		--filters "Name=private-ip-address, Values=$ip" \
		--query 'Reservations[].Instances[].InstanceId' \
		--output text
}

function ec2_name_to_id {
	local name=$1

	aws ec2 describe-instances \
		--filters "Name=tag:Name, Values=$name" \
		--query 'Reservations[].Instances[].InstanceId' \
		--output text
}
