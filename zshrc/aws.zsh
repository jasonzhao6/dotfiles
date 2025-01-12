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
function oecc { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$(ec2_id "$@")"; }
function oasg { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$*"; }
# use [ssm] to ssh into ec2 by instance id, private ip, or name tag
function ssm { # (e.g `ssm <instance-id>`, or `0 ssm` to use the last entry from `args`)
    aws ssm start-session \
        --document-name 'AWS-StartInteractiveCommand' \
        --parameters '{"command": ["sudo -i"]}' \
        --target "$(ec2_id "$@")"
}
function ssm_ { aws ssm start-session --target "$(ec2_id "$@")"; }
function ssm_cmd { # (e.g `ssm-run date <instance-id>`, or `each ssm-run date` to iterate through `args`)
    aws ssm start-session \
        --document-name 'AWS-StartNonInteractiveCommand' \
        --parameters "{\"command\": [\"${(j: :)@[1,-2]}\"]}" \
        --target "$(ec2_id "$*[-1]")" \
    | pgrep --multiline --ignore-case --invert-match "(Starting|\nExiting) session with SessionId: [a-z0-9-@\.]+(\n\n)*"
}
# [p]arameter [s]tore [g]et
function psg { PSG=$(aws ssm get-parameter --name "$1" "$([[ -n "$2" ]] && echo --version "$2")" --query Parameter.Value --output text); [[ $PSG == \{*\} ]] && echo "$PSG" | jq || echo "$PSG"; }
# [s]ecrets [m]anager [g]et / [d]elete
function smg { SMG=$(aws secretsmanager get-secret-value --secret-id "$1" "$([[ -n "$2" ]] && echo --version-id "$2")" --query SecretString --output text); [[ "$SMG" == \{*\} ]] && echo "$SMG" | jq || echo "$SMG"; }
function smd { aws secretsmanager delete-secret --secret-id "$@" --force-delete-without-recovery; }
# [decode] sts message
function decode { aws sts decode-authorization-message --encoded-message "$@" --output text | jq .; }
# helpers
function ec2_id { [[ "$1" =~ ^(i-)?[a-z0-9]{17}$ ]] && { [[ "$1" =~ ^i-.*$ ]] && echo "$1" || echo i-"$1"; } || { [[ "$1" =~ ^[0-9\.]+$ ]] && ip_id "$1" || name_id "$1"; }; }
function id_name { aws ec2 describe-instances --filters "Name=instance-id, Values=$*" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text; }
function ip_id { aws ec2 describe-instances --filters "Name=private-ip-address, Values=$*" --query 'Reservations[].Instances[].InstanceId' --output text; }
function name_id { aws ec2 describe-instances --filters "Name=tag:Name, Values=$*" --query 'Reservations[].Instances[].InstanceId' --output text; }
