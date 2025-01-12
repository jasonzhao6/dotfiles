AWS_NAMESPACE='aws_keymap'
AWS_ALIAS='s'

AWS_KEYMAP=(
	"$AWS_ALIAS·o # List Opal groups"
	"$AWS_ALIAS·o <match> # Filter Opal groups"

	"$AWS_ALIAS·q1 # Use mq01"
	"$AWS_ALIAS·q2 # Use mq02"
	"$AWS_ALIAS·q # MQ restore"
	"$AWS_ALIAS·qo # MQ logout"
	''
	"$AWS_ALIAS·e <prefix> # EC2 search"
)

keymap_init $AWS_NAMESPACE $AWS_ALIAS "${AWS_KEYMAP[@]}"

function aws_keymap {
	keymap_invoke $AWS_NAMESPACE $AWS_ALIAS ${#AWS_KEYMAP} "${AWS_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

source "$ZSHRC_DIR/aws_helpers.zsh"

function aws_keymap_e {
	local prefix="$1"

	ec2_args "Name=tag:Name, Values=$prefix*"
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

function aws_keymap_q {
	mq2 --restore
}

function aws_keymap_q1 {
	mq2 --mq01
}

function aws_keymap_q2 {
	mq2 --mq02
}

function aws_keymap_qo {
	mq2 --logout
}
