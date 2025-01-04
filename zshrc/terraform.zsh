### [T]erra[f]orm
# Config
function tf0 { echo_eval 'export TF_LOG='; }
function tf1 { echo_eval 'export TF_LOG=DEBUG'; }
# [I]nit
# shellcheck disable=SC2120
function tfi { mkdir -p ~/.terraform.cache; terraform init "$@"; }
function tfiu { terraform init -upgrade; }
function tfir { terraform init -reconfigure; }
function tfim { terraform init -migrate-state; }
# Post `tfi` (In case of init error, append ` i|iu|ir|im` to retry)
function tfp { tf_pre "$@" && terraform plan -out=tfplan; }
function tfl { tf_pre "$@" && terraform state list | sed "s/.*/'&'/" | ss; }
function tfo { tf_pre "$@" && terraform output; }
function tfn { tf_pre "$@" && terraform console; }
function tfv { tf_pre "$@" && terraform validate; }
# Post `tfp`
function tfa { terraform apply; }
function tfd { terraform destroy; }
function tfg { terraform show -no_color tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web; }
function tfz { terraform force-unlock "$@"; }
# Post `tfl`
function tfs { terraform state show "$@"; }
function tft { terraform taint "$@"; }
function tfu { terraform untaint "$@"; }
function tfm { terraform state mv "$1" "$2"; }
function tfr { terraform state rm "$@"; }
# [F]ormat a file / folder
function tff { terraform fmt -recursive "$@"; }
# [C]lear cache
function tfc { rm -rf tfplan .terraform ~/.terraform.d; }
function tfcc { rm -rf tfplan .terraform ~/.terraform.d ~/.terraform.cache; }
# Non-prod shortcut
function tfaa { tf_pre "$@" && terraform apply -auto-approve; }

#
# Helpers
#

function tf {
	pushd ~/gh/scratch/tf-debug > /dev/null || return

	if [[ -z $1 ]]; then
		terraform console
	else
		echo "local.$1" | terraform console
	fi

	popd > /dev/null || return
}

function tf_pre {
    [[ -z $1 ]] && return

    for var in "$@"; do
        case $var in
            e) tfe;;
            i) tfi;;
            iu) tfiu;;
            ir) tfir;;
            im) tfim;;
        esac
    done
}
