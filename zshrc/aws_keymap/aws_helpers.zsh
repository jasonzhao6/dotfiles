function ec2_args {
	local name="$1"

	aws ec2 describe-instances \
		--region "$AWS_DEFAULT_REGION" \
		--filters "$name" 'Name=instance-state-name, Values=running' \
		--query 'Reservations[].Instances[].[PrivateIpAddress, LaunchTime, Tags[?Key==`Name` || Key==`aws:autoscaling:groupName`].Value|[0]]' \
		--output text |
			sort --key=3 |
			sed 's/+00:00\t/Z  /g' |
			args_keymap_so
}

function ec2_ip_to_id {
	local ip=$1

	aws ec2 describe-instances \
		--region "$AWS_DEFAULT_REGION" \
		--filters "Name=private-ip-address, Values=$ip" \
		--query 'Reservations[].Instances[].InstanceId' \
		--output text
}

function ec2_name_to_id {
	local name=$1

	aws ec2 describe-instances \
		--region "$AWS_DEFAULT_REGION" \
		--filters "Name=tag:Name, Values=$name" \
		--query 'Reservations[].Instances[].InstanceId' \
		--output text
}
