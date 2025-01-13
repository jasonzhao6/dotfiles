# Set [n]ame[s]pace

# General

# Pod shortcuts

function kubectl_keymap_p {
	kubectl port-forward "$@"
}

# Get resource as [j]son / [y]aml
function kubectl_keymap_j {
	[[ -n $1 ]] && kubectl get "$@" -o json > ~/Documents/k8.json | jq
}

function kubectl_keymap_jj {
	cat ~/Documents/k8.json
}

function kubectl_keymap_y {
	[[ -n $1 ]] && kubectl get "$@" -o yaml > ~/Documents/k8.yaml | cat
}

function kubectl_keymap_yy {
	cat ~/Documents/k8.yaml
}

# [Q]uery saved json output
function kubectl_keymap_q {
	jq "${@:-.}" ~/Documents/k8.json
}
