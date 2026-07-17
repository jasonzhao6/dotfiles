function aws_helpers_ec2_args {
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

function aws_helpers_ec2_ip_to_id {
	local ip=$1

	aws ec2 describe-instances \
		--region "$AWS_DEFAULT_REGION" \
		--filters "Name=private-ip-address, Values=$ip" \
		--query 'Reservations[].Instances[].InstanceId' \
		--output text
}

function aws_helpers_ec2_name_to_id {
	local name=$1

	aws ec2 describe-instances \
		--region "$AWS_DEFAULT_REGION" \
		--filters "Name=tag:Name, Values=$name" \
		--query 'Reservations[].Instances[].InstanceId' \
		--output text
}

function aws_helpers_mysql_string {
	local secret=$1

	# A MySQL cred is json with `host` & `username` whose `engine` (if present) is `mysql`
	local host port user
	echo "$secret" | jq --raw-output '
		select((.engine // "mysql") == "mysql") |
		select(.host and .username) |
		"\(.host)\t\(.port // 3306)\t\(.username)"
	' 2>/dev/null | IFS=$'\t' read -r host port user

	[[ -z $host ]] && return

	# Leave `-p` bare so mysql prompts for the password interactively
	echo
	echo "mysql -h $host -P $port -u $user -p"
}
