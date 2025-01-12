AWS_NAMESPACE='aws_keymap'
AWS_ALIAS='s'

AWS_KEYMAP=(
	"$AWS_ALIAS${KEYMAP_DOT}o # List Opal groups"
	"$AWS_ALIAS${KEYMAP_DOT}o <match> # Filter Opal groups"
	''
	"$AWS_ALIAS${KEYMAP_DOT}0 # MQ logout"
	"$AWS_ALIAS${KEYMAP_DOT}1 # MQ login to 01"
	"$AWS_ALIAS${KEYMAP_DOT}2 # MQ login to 02"
	"$AWS_ALIAS${KEYMAP_DOT}q # MQ restore"
	''
	"$AWS_ALIAS${KEYMAP_DOT}e1 # Use us-east-1 region"
	"$AWS_ALIAS${KEYMAP_DOT}e2 # Use us-east-2 region"
	"$AWS_ALIAS${KEYMAP_DOT}w2 # Use us-west-2 region"
	"$AWS_ALIAS${KEYMAP_DOT}c1 # Use eu-central-1 region"
	''
	"$AWS_ALIAS${KEYMAP_DOT}e <prefix> # EC2 search"
	"$AWS_ALIAS${KEYMAP_DOT}a <prefix> # ASG search"
	"$AWS_ALIAS${KEYMAP_DOT}s # SSM start session with \`sudo -i\`"
	"$AWS_ALIAS${KEYMAP_DOT}sc # SSM start session with command"
	"$AWS_ALIAS${KEYMAP_DOT}sm # SSM start session"
	"$AWS_ALIAS${KEYMAP_DOT}oe <ec2 id> # Open new tab to the specified EC2 instance"
	"$AWS_ALIAS${KEYMAP_DOT}oa <asg id> # Open new tab to the specified ASG group"
	''
	"$AWS_ALIAS${KEYMAP_DOT}m <name> # Secret Manager get"
	"$AWS_ALIAS${KEYMAP_DOT}md <name> # Secret Manager delete"
	"$AWS_ALIAS${KEYMAP_DOT}p <name> # Parameter Store get"
	"$AWS_ALIAS${KEYMAP_DOT}t <message> # STS decode"
)

keymap_init $AWS_NAMESPACE $AWS_ALIAS "${AWS_KEYMAP[@]}"

function aws_keymap {
	keymap_invoke $AWS_NAMESPACE $AWS_ALIAS ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/aws_helpers.zsh"

export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}

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
	local prefix=$1

	ec2_args "Name=tag:aws:autoscaling:groupName, Values=$prefix*"
}

function aws_keymap_c1 {
	echo_eval 'export AWS_DEFAULT_REGION=eu-central-1'
}

function aws_keymap_e {
	local prefix=$1

	ec2_args "Name=tag:Name, Values=$prefix*"
}

function aws_keymap_e1 {
	echo_eval 'export AWS_DEFAULT_REGION=us-east-1'
}

function aws_keymap_e2 {
	echo_eval 'export AWS_DEFAULT_REGION=us-east-2'
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

for aws_keymap_mq2 in "$HOME/.config/zsh/config.d/"*.zsh; do
	source "${aws_keymap_mq2}"
done; unset aws_keymap_mq2

function aws_keymap_oa {
	local id=$*

	open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$id"
}

function aws_keymap_oe {
	local id; id=$(ec2_get_id "$@")

	open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$id"
}

function aws_keymap_p {
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
