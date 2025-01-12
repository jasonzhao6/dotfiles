#	"$AWS_ALIAS·re # Use us-east-1 region"
#	"$AWS_ALIAS·re2 # Use us-east-2 region"
#	"$AWS_ALIAS·rw2 # Use us-west-2 region"
#	"$AWS_ALIAS·rc # Use eu-central-1 region"

### AWS
# select region
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}
function c1 { echo_eval 'export AWS_DEFAULT_REGION=eu-central-1'; }
function e1 { echo_eval 'export AWS_DEFAULT_REGION=us-east-1'; }
function e2 { echo_eval 'export AWS_DEFAULT_REGION=us-east-2'; }
function w1 { echo_eval 'export AWS_DEFAULT_REGION=us-west-1'; }
function w2 { echo_eval 'export AWS_DEFAULT_REGION=us-west-2'; }
# open [ec2] / [asg] page by resource id
function oec2 { oecc "$@"; }
function oecc { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$(ec2_get_id "$@")"; }
function oasg { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$*"; }
# use [ssm] to ssh into ec2 by instance id, private ip, or name tag
# [p]arameter [s]tore [g]et
function psg { PSG=$(aws ssm get-parameter --name "$1" "$([[ -n "$2" ]] && echo --version "$2")" --query Parameter.Value --output text); [[ $PSG == \{*\} ]] && echo "$PSG" | jq || echo "$PSG"; }
# [s]ecrets [m]anager [g]et / [d]elete
function smg { SMG=$(aws secretsmanager get-secret-value --secret-id "$1" "$([[ -n "$2" ]] && echo --version-id "$2")" --query SecretString --output text); [[ "$SMG" == \{*\} ]] && echo "$SMG" | jq || echo "$SMG"; }
function smd { aws secretsmanager delete-secret --secret-id "$@" --force-delete-without-recovery; }
# [decode] sts message
function decode { aws sts decode-authorization-message --encoded-message "$@" --output text | jq .; }
# helpers
