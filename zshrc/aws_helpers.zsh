function ec2_args {
	local prefix="$1"

	aws ec2 describe-instances \
		--filters "$prefix" 'Name=instance-state-name, Values=running' \
		--query 'Reservations[].Instances[].[PrivateIpAddress, LaunchTime, Tags[?Key==`Name` || Key==`aws:autoscaling:groupName`].Value|[0]]' \
		--output text |
			sort --key=3 |
			sed 's/+00:00\t/Z  /g' |
			args_keymap_so
}
