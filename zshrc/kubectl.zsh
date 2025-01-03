### [K]ubectl
# resources ref: g[r]ep / [s]ave / e[x]plain
function kr { cat ~/Documents/k8.txt | grep "$*" | ss; }
function ks { kubectl api-resources > ~/Documents/k8.txt; }
function kx { kubectl explain "$@"; }
# set [n]ame[s]pace
function kns { kubectl config set-context --current --namespace "$@"; }
# general
function k { kubectl "$@"; }
function kd { kubectl describe "$@"; }
function ke { kubectl exec "$@"; }
function kg { kubectl get "$@"; }
function kk { kubectl get "$@" | s; }
# pod shortcuts
function kb { kubectl exec -it "$@" -- bash; }
function kc { kubectl exec "${@[-1]}" -- "${@[1,-2]}"; }
function kl { kubectl logs "$@"; }
function kp { kubectl port-forward "$@"; }
# get resource as [j]son / [y]aml
function kj { [[ -n $1 ]] && kubectl get "$@" -o json > ~/Documents/k8.json | jq; }
function kjj { cat ~/Documents/k8.json; }
function ky { [[ -n $1 ]] && kubectl get "$@" -o yaml > ~/Documents/k8.yaml | cat; }
function kyy { cat ~/Documents/k8.yaml; }
# [q]uery saved json output
function kq { jq "${@:-.}" ~/Documents/k8.json; }

# TODO move to eof once stable
### Kubectl keymap
#  1   2   3   4   5  |  6   7   8   9   0
#             [p] [y] |  f  [g] [c] [r] [l]
#  a   o  [e]  u   i  | [d]  h   t   n  [s]
#     [q] [j] [k] [x] | [b]  m   w   v   z
