#
# Lis[t]
#

LIST_TYPES=(
	't o # Opal'
	't za [partial name] # Zsh aliases'
	't zf [partial name] # Zsh functions'
)

function t {
	local type_prefix=$1

	if [[ -z $type_prefix ]]; then
		list_usage
	else
		for type in "${LIST_TYPES[@]}"; do
			[[ $type == $type_prefix* ]] && $(echo "$type" | awk '{print $1}') "${@:2}"
		done
	fi
}

# To be overwritten by `.zshrc.secrets`
OPAL=(
	'non-secret-placeholder-1 url-1'
	'non-secret-placeholder-2 url-2'
)

function opal {
	print -l "${OPAL[@]}" | sort | column -t | ss
}

function zsh_aliases {
	alias | egrep ".*$1.*" | bw | ss
}

function zsh_functions {
	typeset -f | pgrep -o "^[\S]*$1[\S]* (?=\(\))" | bw | ss
}

#
# Helpers
#

function list_usage {
	cat <<-eof

		Usage:

		  $(gray_fg '` t `')
		  $(gray_fg '` t [type] [args]... `')

		Types:

	eof

	local max_command_size=0

	for type in "${LIST_TYPES[@]}"; do
		local command_size="${#type% \#*}"
		[[ $command_size -gt $max_command_size ]] && max_command_size=$command_size
	done

	for type in "${LIST_TYPES[@]}"; do
		echo -n "  $LIST_PROMPT"
		list_type_coloring "$type" "$max_command_size"
	done
}

LIST_PROMPT=$(yellow_fg '$ ')

function list_type_coloring {
	local list_type=$1
	local command_size=$2

	local command="${list_type% \#*}"
	local comment="# ${list_type#*\# }"

	printf "%-*s %s\n" "$command_size" "$command" "$(gray_fg $comment)"
}

[[ -n $ZSHRC_UNDER_TEST ]] && LIST_TYPES+=('list_test <arg1> <arg2>')

function list_test {
	echo "arg1: $1"
	echo "arg2: $2"
}
