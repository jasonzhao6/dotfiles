AWS_NAMESPACE='aws_keymap'
AWS_ALIAS='s'
AWS_DOT="${AWS_ALIAS}${KEYMAP_DOT}"

AWS_KEYMAP=(
	"${AWS_DOT}o # List Opal groups"
	"${AWS_DOT}o <match>* <-mismatch>* # Filter Opal groups"
	''
	"${AWS_DOT}1 # MQ login to 01"
	"${AWS_DOT}2 # MQ login to 02"
	"${AWS_DOT}0 # MQ logout"
	"${AWS_DOT}11 # MQ logout, then login to 01"
	"${AWS_DOT}22 # MQ logout, then login to 02"
	''
	"${AWS_DOT}e1 # Use us-east-1 region"
	"${AWS_DOT}e2 # Use us-east-2 region"
	"${AWS_DOT}w2 # Use us-west-2 region"
	"${AWS_DOT}c1 # Use eu-central-1 region"
	''
	"${AWS_DOT}e <name> # EC2 search"
	"${AWS_DOT}ee <ec2 id> # EC2 open in new tab"
	"${AWS_DOT}a <name> # ASG search"
	"${AWS_DOT}aa <asg id> # ASG open in new tab"
	"${AWS_DOT}c # Copy history bindings"
	"${AWS_DOT}s # SSM start session with \`sudo -i\`"
	"${AWS_DOT}sc # SSM start session with command"
	"${AWS_DOT}sm # SSM start session"
	''
	"${AWS_DOT}m <name> # Secret Manager get latest version"
	"${AWS_DOT}m <name> <version> # Secret Manager get by version"
	"${AWS_DOT}md <name> # Secret Manager delete"
	"${AWS_DOT}r <name> # Parameter Store get latest version"
	"${AWS_DOT}t <message> # STS decode"
	''
	"${AWS_DOT}n <name> # SNS search"
	"${AWS_DOT}nn <topic arn> # SNS open in new tab"
	''
	"${AWS_DOT}q <name> # SQS search"
	"${AWS_DOT}qq <queue url> # SQS open in new tab"
	"${AWS_DOT}qg <queue url> # SQS get stats"
	"${AWS_DOT}qr <queue url> <count>? # SQS receive message"
	"${AWS_DOT}qpurge <queue url> # SQS purge"
	''
	"${AWS_DOT}p <name> # Code Pipeline search"
	"${AWS_DOT}pp <name> # Code Pipeline get latest status"
)

keymap_init $AWS_NAMESPACE $AWS_ALIAS "${AWS_KEYMAP[@]}"

function aws_keymap {
	keymap_show $AWS_NAMESPACE $AWS_ALIAS ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}
AWS_URL="https://$AWS_DEFAULT_REGION.console.aws.amazon.com"

source "$ZSHRC_DIR/$AWS_NAMESPACE/aws_helpers.zsh"

function aws_keymap_0 {
	mqc logout
}

function aws_keymap_1 {
	mqc --mq01
}

function aws_keymap_11 {
	mqc logout
	mqc --mq01
}

function aws_keymap_2 {
	mqc --mq02
}

function aws_keymap_22 {
	mqc logout
	mqc --mq02
}

function aws_keymap_a {
	local name=$1

	ec2_args "Name=tag:aws:autoscaling:groupName, Values=*$name*"
}

function aws_keymap_aa {
	local id=$*

	open "$AWS_URL/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$id"
}

function aws_keymap_c {
	cat <<-eof | pbcopy
		bind '"\e[A": history-search-backward'
		bind '"\e[B": history-search-forward'
	eof

	echo
	green_bar 'History bindings copied to pasteboard'
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

	open "$AWS_URL/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$id"
}

function aws_keymap_m {
	local name=$1
	local version=$2

	# If `version` is specified, get by version
	local version_args; [[ -n "$version" ]] && version_args=(--version-id "$version")

	# Get secret
	local secret; secret=$(
		aws secretsmanager get-secret-value \
			--region "$AWS_DEFAULT_REGION" \
			--secret-id "$name" \
			"${version_args[@]}" \
			--query SecretString \
			--output text
	)

	# If output contains json, prettify with `jq`
	[[ "$secret" == \{*\} ]] && echo "$secret" | jq || echo "$secret"
}

function aws_keymap_md {
	local name=$1

	aws secretsmanager delete-secret \
		--region "$AWS_DEFAULT_REGION" \
		--secret-id "$name" \
		--force-delete-without-recovery
}

function aws_keymap_n {
	local name=$1

	aws sns list-topics \
		--region "$AWS_DEFAULT_REGION" |
			jq --raw-output '.Topics[].TopicArn' | args_keymap_s "$name"
}

function aws_keymap_nn {
	local arn=$1

	open "$AWS_URL/sns/v3/home?region=$AWS_DEFAULT_REGION#/topic/$arn"
}

# To be overwritten by `ZSHRC_SECRETS`
AWS_OPAL=(
	'role_name_1 request_page_url_1'
	'role_name_2 request_page_url_2'
)

function aws_keymap_o {
	local filters=("$@")

	print -l "${AWS_OPAL[@]}" | sort | column -t | args_keymap_s "${filters[@]}"
}

function aws_keymap_p {
	local name=$1

	aws codepipeline list-pipelines \
		--region "$AWS_DEFAULT_REGION" \
		--query "pipelines[?contains(name, '$name')].[name]" \
		--output text |
		args_keymap_s "$name"
}

AWS_KEYMAP_PP_STATUS='stageStates[-1].actionStates[-1].latestExecution.status'
AWS_KEYMAP_PP_TIMESTAMP='stageStates[-1].actionStates[-1].latestExecution.lastStatusChange'

function aws_keymap_pp {
	local name=$1

	aws codepipeline get-pipeline-state \
		--region "$AWS_DEFAULT_REGION" \
		--name "$name" \
		--query "[pipelineName, $AWS_KEYMAP_PP_STATUS, $AWS_KEYMAP_PP_TIMESTAMP]" \
		--output text
}

function aws_keymap_q {
	local name=$1

	aws sqs list-queues \
		--region "$AWS_DEFAULT_REGION" |
			jq --raw-output '.QueueUrls[]' | args_keymap_s "$name"
}

function aws_keymap_qg {
	local url=$1

	aws sqs get-queue-attributes \
		--region "$AWS_DEFAULT_REGION" \
		--queue-url "$url" \
		--attribute-names ApproximateNumberOfMessages ApproximateNumberOfMessagesNotVisible | jq
}

function aws_keymap_qpurge {
	local url=$1

	aws sqs purge-queue \
		--region "$AWS_DEFAULT_REGION" \
		--queue-url "$url"

	aws_keymap_qg "$url"
}

function aws_keymap_qq {
	local url; url=$(echo "$1" | encode_url)

	open "$AWS_URL/sqs/v3/home?region=$AWS_DEFAULT_REGION#/queues/$url"
}

function aws_keymap_qr {
	local url=$1
	local count=${2:-1}

	aws sqs receive-message \
		--region "$AWS_DEFAULT_REGION" \
		--queue-url "$url" \
		--max-number-of-messages "$count" \
		--visibility-timeout 5 \
		--wait-time-seconds 1 |
			jq '.Messages[].Body | fromjson'
}

function aws_keymap_r {
	local name=$1

	local parameter; parameter=$(
		aws ssm get-parameter \
			--region "$AWS_DEFAULT_REGION" \
			--name "$name"	\
			--query Parameter.Value \
			--output text
	)

	# If it's json, prettify with `jq`
	[[ $parameter == \{*\} ]] && echo "$parameter" | jq || echo "$parameter"
}

function aws_keymap_s {
	local id=$1

	aws ssm start-session \
		--region "$AWS_DEFAULT_REGION" \
		--document-name 'AWS-StartInteractiveCommand' \
		--parameters '{"command": ["sudo -i"]}' \
		--target "$(ec2_get_id "$id")"
}

AWS_KEYMAP_SC_REGEX="(Starting|\nExiting) session with SessionId: [a-z0-9-@\.]+(\n\n)*"

function aws_keymap_sc {
	local command=${(j: :)@[1,-2]}
	local id="$*[-1]"

	aws ssm start-session \
		--region "$AWS_DEFAULT_REGION" \
		--document-name 'AWS-StartNonInteractiveCommand' \
		--parameters "{\"command\": [\"$command\"]}" \
		--target "$(ec2_get_id "$id")" |
			pgrep --multiline --ignore-case --invert-match "$AWS_KEYMAP_SC_REGEX"
}

function aws_keymap_sm {
	aws ssm start-session \
		--region "$AWS_DEFAULT_REGION" \
		--target "$(ec2_get_id "$@")"
}

function aws_keymap_t {
	local message=$*

	aws sts decode-authorization-message
		--region "$AWS_DEFAULT_REGION" \
		--encoded-message "$message" --output text |
			jq .
}

function aws_keymap_w2 {
	echo_eval 'export AWS_DEFAULT_REGION=us-west-2'
}
