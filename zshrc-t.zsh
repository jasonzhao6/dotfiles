#
# Lis[t]
#

function t { [[ -z $1 ]] && echo 'to # no args' | save-args || echo-eval "$@[-1] $@[1,-2]" }

#
# List type: Opal
#

function to { for k v in ${(kv)T_OPAL}; do echo $v $k; done | sort -k2,2 | column -t | s }
