#
# Zsh prompt
#
# - Line 1: <empty>
# - Line 2:
#   - Variation A: @repo/path #branch (sts-info region-info tf-info)
#   - Variation B: ~/home/path (...)
#   - Variation C: /root/path (...)
# - Line 3: $ █
#

setopt PROMPT_SUBST

PROMPT=\
$'\n'\
'%{%F{yellow}%}% ${${PWD/#$HOME/~}/\~\/gh\//@}'\
'%{%F{cyan}%}% $(branch-info)'\
'%{%F{green}%}% $(sts-info)'\
'%{%F{magenta}%}% $(region-info)'\
'%{%F{yellow}%}% $(tf-info)'\
$'\n'\
'%{%F{yellow}%}% $'\
'%{%f%}%  '

#
# Helpers
#

function branch-info {
	BRANCH_INFO=$(branch 2> /dev/null)
	[[ -n $BRANCH_INFO ]] && echo " #$BRANCH_INFO"
}

STS_INFO_DIR="$HOME/.zshrc.sts-info.d"

function sts-info {
	[[ -z $AWS_PROFILE ]] && return

	if [[ ! -e $STS_INFO_DIR/$AWS_PROFILE ]]; then
		local account=$(aws iam list-account-aliases --query 'AccountAliases[0]' --output text)
		local role=$(aws sts get-caller-identity --query Arn --output text | awk -F'/' '{print $2}' | awk -F'_' '{print $2}')

		mkdir -p $STS_INFO_DIR
		echo "$(account)::$(role)" > $STS_INFO_DIR/$AWS_PROFILE
	fi

	echo " $(<$STS_INFO_DIR/$AWS_PROFILE)"
}

function region-info {
	[[ -n $AWS_PROFILE ]] && echo " $AWS_DEFAULT_REGION"
}

function tf-info {
	[[ -n $TF_VAR_datadog_api_key ]] && echo ' TF_VAR'
}
