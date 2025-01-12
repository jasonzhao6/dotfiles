#
# Zsh prompt
#
# - Line 1: <empty>
# - Line 2:
#   - Variation A: @repo/path #branch (sts_info region_info tf_info)
#   - Variation B: ~/home/path (...)
#   - Variation C: /root/path (...)
# - Line 3: $ █
#

setopt PROMPT_SUBST

# shellcheck disable=SC2034
PROMPT=\
$'\n'\
'%{%F{yellow}%}% ${${PWD/#$HOME/~}/\~\/gh\//@}'\
'%{%F{cyan}%}% $(branch_info)'\
'%{%F{green}%}% $(sts_info)'\
'%{%F{magenta}%}% $(region_info)'\
'%{%F{yellow}%}% $(tf_info)'\
$'\n'\
'%{%F{yellow}%}% $'\
'%{%f%}%  '

#
# Helpers
#

function branch_info {
	local branch_info; branch_info=$(github_keymap_nb 2> /dev/null)
	[[ -n $branch_info ]] && echo " #$branch_info"
}

STS_INFO_DIR="$HOME/.zshrc.sts_info.d"

function sts_info {
	[[ -z $AWS_PROFILE ]] && return

	if [[ ! -e $STS_INFO_DIR/$AWS_PROFILE ]]; then
		local account; account=$(aws iam list_account-aliases --query 'AccountAliases[0]' --output text)
		local role; role=$(aws sts get-caller-identity --query Arn --output text | awk -F'/' '{print $2}' | awk -F'_' '{print $2}')

		mkdir -p "$STS_INFO_DIR"
		echo "$account::$role" > "$STS_INFO_DIR"/"$AWS_PROFILE"
	fi

	echo " $(<"$STS_INFO_DIR"/"$AWS_PROFILE")"
}

function region_info {
	[[ -n $AWS_PROFILE ]] && echo " $AWS_DEFAULT_REGION"
}

function tf_info {
	[[ -n $TF_VAR_datadog_api_key ]] && echo ' TF_VAR'
}
