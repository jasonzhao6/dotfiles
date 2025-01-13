# Set [n]ame[s]pace
function kubectl_keymap_ns {
	kubectl config set-context --current --namespace "$@"
}

# General
function kubectl_keymap_ {
	kubectl "$@"
}

function kubectl_keymap_d {
	kubectl describe "$@"
}

function kubectl_keymap_e {
	kubectl exec "$@"
}

function kubectl_keymap_g {
	kubectl get "$@"
}

function kubectl_keymap_k {
	kubectl get "$@" | s
}

# Pod shortcuts
function kubectl_keymap_b {
	kubectl exec -it "$@" -- bash
}

function kubectl_keymap_c {
	kubectl exec "${@[-1]}" -- "${@[1,-2]}"
}

function kubectl_keymap_l {
	kubectl logs "$@"
}

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
