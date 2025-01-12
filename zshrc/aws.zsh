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

function decode { aws sts decode-authorization-message --encoded-message "$@" --output text | jq .; }
# helpers
