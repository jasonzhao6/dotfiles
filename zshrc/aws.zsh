### AWS
# select region
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-'us-east-1'}
function c1 { echo_eval 'export AWS_DEFAULT_REGION=eu-central-1' }
function e1 { echo_eval 'export AWS_DEFAULT_REGION=us-east-1' }
function e2 { echo_eval 'export AWS_DEFAULT_REGION=us-east-2' }
function w1 { echo_eval 'export AWS_DEFAULT_REGION=us-west-1' }
function w2 { echo_eval 'export AWS_DEFAULT_REGION=us-west-2' }
# find [ec2] / [asg] instances by name tag prefix
function ec2 { ecc $@ }
function ecc { ec2-args "Name=tag:Name, Values=$@*" }
function asg { ec2-args "Name=tag:aws:autoscaling:groupName, Values=$@*" }
# open [ec2] / [asg] page by resource id
function oec2 { oecc $@ }
function oecc { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#InstanceDetails:instanceId=$(ec2-id $@)" }
function oasg { open "https://$AWS_DEFAULT_REGION.console.aws.amazon.com/ec2/home?region=$AWS_DEFAULT_REGION#AutoScalingGroupDetails:id=$@" }
# use [ssm] to ssh into ec2 by instance id, private ip, or name tag
function ssm { # (e.g `ssm <instance-id>`, or `0 ssm` to use the last entry from `args`)
    aws ssm start-session \
        --document-name 'AWS-StartInteractiveCommand' \
        --parameters '{"command": ["sudo -i"]}' \
        --target $(ec2-id $@)
}
function ssm_ { aws ssm start-session --target $(ec2-id $@) }
function ssm-cmd { # (e.g `ssm-run date <instance-id>`, or `each ssm-run date` to iterate through `args`)
    aws ssm start-session \
        --document-name 'AWS-StartNonInteractiveCommand' \
        --parameters "{\"command\": [\"${(j: :)@[1,-2]}\"]}" \
        --target $(ec2-id $@[-1]) \
    | pcregrep --multiline --ignore-case --invert-match "(Starting|\nExiting) session with SessionId: [a-z0-9-@\.]+(\n\n)*"
}
# [p]arameter [s]tore [g]et
function psg { PSG=$(aws ssm get-parameter --name $1 $([[ -n $2 ]] && echo --version $2) --query Parameter.Value --output text); [[ $PSG == {*} ]] && echo $PSG | jq || echo $PSG }
# [s]ecrets [m]anager [g]et / [d]elete
function smg { SMG=$(aws secretsmanager get-secret-value --secret-id $1 $([[ -n $2 ]] && echo --version-id $2) --query SecretString --output text); [[ $SMG == {*} ]] && echo $SMG | jq || echo $SMG }
function smd { aws secretsmanager delete-secret --secret-id $@ --force-delete-without-recovery }
# [decode] sts message
function decode { aws sts decode-authorization-message --encoded-message $@ --output text | jq . }
# helpers
function ec2-args { aws ec2 describe-instances --filters $@ 'Name=instance-state-name, Values=running' --query "$(ec2-query)" --output text | sort --key=3 | sed 's/+00:00\t/Z  /g' | s }
function ec2-query { echo 'Reservations[].Instances[].[PrivateIpAddress, LaunchTime, Tags[?Key==`Name` || Key==`aws:autoscaling:groupName`].Value|[0]]' }
function ec2-id { [[ $@ =~ ^(i-)?[a-z0-9]{17}$ ]] && { [[ $@ =~ ^i-.*$ ]] && echo $@ || echo i-$@ } || { [[ $@ =~ ^[0-9\.]+$ ]] && ip-id $@ || name-id $@ } }
function id-name { aws ec2 describe-instances --filters "Name=instance-id, Values=$@" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text }
function ip-id { aws ec2 describe-instances --filters "Name=private-ip-address, Values=$@" --query 'Reservations[].Instances[].InstanceId' --output text }
function name-id { aws ec2 describe-instances --filters "Name=tag:Name, Values=$@" --query 'Reservations[].Instances[].InstanceId' --output text }
