AWS_NAMESPACE='aws_keymap'
AWS_ALIAS='s'
AWS_DOT="${AWS_ALIAS}${KEYMAP_DOT}"

AWS_KEYMAP=(
	"${AWS_DOT}o # List Opal groups"
	"${AWS_DOT}o <match> # Filter Opal groups"
	''
	"${AWS_DOT}0 # MQ logout"
	"${AWS_DOT}1 # MQ login to 01"
	"${AWS_DOT}2 # MQ login to 02"
	"${AWS_DOT}q # MQ restore"
	''
	"${AWS_DOT}e1 # Use us-east-1 region"
	"${AWS_DOT}e2 # Use us-east-2 region"
	"${AWS_DOT}w2 # Use us-west-2 region"
	"${AWS_DOT}c1 # Use eu-central-1 region"
	''
	"${AWS_DOT}e <name> # EC2 search"
	"${AWS_DOT}a <name> # ASG search"
	"${AWS_DOT}ee <ec2 id> # Open new tab to an EC2 instance"
	"${AWS_DOT}aa <asg id> # Open new tab to an ASG group"
	"${AWS_DOT}s # SSM start session with \`sudo -i\`"
	"${AWS_DOT}sc # SSM start session with command"
	"${AWS_DOT}sm # SSM start session"
	''
	"${AWS_DOT}m <name> # Secret Manager get"
	"${AWS_DOT}md <name> # Secret Manager delete"
	"${AWS_DOT}ps <name> # Parameter Store get"
	"${AWS_DOT}t <message> # STS decode"
	''
	"${AWS_DOT}p <name> # Code Pipeline search"
	"${AWS_DOT}pp <name> # Code Pipeline get latest status"
)

keymap_init $AWS_NAMESPACE $AWS_ALIAS "${AWS_KEYMAP[@]}"

function aws_keymap {
	keymap_invoke $AWS_NAMESPACE $AWS_ALIAS ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

source "$ZSHRC_DIR/aws_helpers.zsh"

for aws_keymap_mq2 in "$HOME/.config/zsh/config.d/"*.zsh; do
	source "${aws_keymap_mq2}"
done; unset aws_keymap_mq2

function aws_keymap_0 {
	mq2 --logout
}

function aws_keymap_1 {
	mq2 --mq01
}

function aws_keymap_2 {
	mq2 --mq02
}

function aws_keymap_a {
	local name=$1

	ec2_args "Name=tag:aws:autoscaling:groupName, Values=*$name*"
}

function aws_keymap_aa {
	local id=$*

	open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$id"
}

function aws_keymap_c1 {
	echo_eval 'export AWS_DEFAULT_REGION=eu-central-1'
}

function aws_keymap_e {
	local name=$1

	ec2_args "Name=tag:Name, Values=*$name*"
}

function aws_keymap_e1 {
	echo_eval 'export AWS_DEFAULT_REGION=us-east-1'
}

function aws_keymap_e2 {
	echo_eval 'export AWS_DEFAULT_REGION=us-east-2'
}

function aws_keymap_ee {
	local id; id=$(ec2_get_id "$@")

	open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$id"
}

function aws_keymap_m {
	local name=$1
	local version=$2

	local secret
	if [[ -z "$version" ]]; then
		secret=$(
			aws secretsmanager get-secret-value \
				--secret-id "$name" \
				--query SecretString \
				--output text
		)
	else
		secret=$(
			aws secretsmanager get-secret-value \
				--secret-id "$name" \
				--version-id "$version" \
				--query SecretString \
				--output text
		)
	fi

	# If it's json, prettify with `jq`
	[[ "$secret" == \{*\} ]] && echo "$secret" | jq || echo "$secret"
}

function aws_keymap_md {
	local name=$1

	aws secretsmanager delete-secret \
		--secret-id "$name" \
		--force-delete-without-recovery
}

# To be overwritten by `$ZSHRC_SECRETS`
AWS_OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
	'non-secret-placeholder-20 url-20'
)

function aws_keymap_o {
	local filters=("$@")

	print -l "${AWS_OPAL[@]}" | sort | column -t | args_keymap_s "${filters[@]}"
}

function aws_keymap_p {
	local name=$1

	aws codepipeline list-pipelines --query "pipelines[?contains(name, '$name')].[name]" --output text | as "$name"
}

function aws_keymap_pp {
	local name=$1

	aws codepipeline get-pipeline-state --name "$name" --query "[pipelineName, stageStates[-1].actionStates[-1].latestExecution.status, stageStates[-1].actionStates[-1].latestExecution.lastStatusChange]" --output text
}

function aws_keymap_ps {
	local name=$1

	local parameter; parameter=$(
		aws ssm get-parameter \
			--name "$name"	\
			--query Parameter.Value \
			--output text
	)

	# If it's json, prettify with `jq`
	[[ $parameter == \{*\} ]] && echo "$parameter" | jq || echo "$parameter"
}

function aws_keymap_q {
	mq2 --restore
}

function aws_keymap_s { # (e.g `ssm <instance-id>`, or `0 ssm` to use the last entry from `args`)
	local id=$1

	aws ssm start-session \
		--document-name 'AWS-StartInteractiveCommand' \
		--parameters '{"command": ["sudo -i"]}' \
		--target "$(ec2_get_id "$id")"
}

function aws_keymap_sc { # (e.g `ssm-run date <instance-id>`, or `each ssm-run date` to iterate through `args`)
	local command=${(j: :)@[1,-2]}
	local id="$*[-1]"

	aws ssm start-session \
		--document-name 'AWS-StartNonInteractiveCommand' \
		--parameters "{\"command\": [\"$command\"]}" \
		--target "$(ec2_get_id "$id")" |
			pgrep --multiline --ignore-case --invert-match "(Starting|\nExiting) session with SessionId: [a-z0-9-@\.]+(\n\n)*"
}

function aws_keymap_sm {
	aws ssm start-session --target "$(ec2_get_id "$@")"
}

function aws_keymap_t {
	local message=$*

	aws sts decode-authorization-message --encoded-message "$message" --output text | jq .
}

function aws_keymap_w2 {
	echo_eval 'export AWS_DEFAULT_REGION=us-west-2'
}
