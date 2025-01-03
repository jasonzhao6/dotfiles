# TODO

### [T]erra[f]orm
# config
function tf0 { echo_eval 'export TF_LOG=' }
function tf1 { echo_eval 'export TF_LOG=DEBUG' }
# [i]nit
function tfi { mkdir -p ~/.terraform.cache; terraform init $@ }
function tfiu { terraform init -upgrade }
function tfir { terraform init -reconfigure }
function tfim { terraform init -migrate-state }
# post `tfi`
# (e.g `tfp` to plan, `tfp iu` to init upgrade then plan)
function tfp { tf-pre $@ && terraform plan -out=tfplan }
function tfl { tf-pre $@ && terraform state list | sed "s/.*/'&'/" | ss }
function tfo { tf-pre $@ && terraform output }
function tfn { tf-pre $@ && terraform console }
function tfv { tf-pre $@ && terraform validate }
# post `tfp`
function tfa { terraform apply }
function tfd { terraform destroy }
function tfg { terraform show -no_color tfplan | sed 's/user_data.*/user_data [REDACTED]/' | gh gist create --web }
function tfz { terraform force-unlock $@ }
# post `tfl`
function tfs { terraform state show $@ }
function tft { terraform taint $@ }
function tfu { terraform untaint $@ }
function tfm { terraform state mv $1 $2 }
function tfr { terraform state rm $@ }
# [f]ormat file / folder
function tff { terraform fmt -recursive $@ }
# [c]lear cache
function tfc { rm -rf tfplan .terraform ~/.terraform.d }
function tfcc { rm -rf tfplan .terraform ~/.terraform.d ~/.terraform.cache }
# non-prod shortcut
function tfaa { tf-pre $@ && terraform apply -auto-approve }
# helpers
function tf { pushd ~/gh/scratch/tf-debug > /dev/null; [[ -z $1 ]] && terraform console || echo "local.$@" | terraform console; popd > /dev/null }
function tf-pre {
    [[ -z $1 ]] && return

    for var in $@; do
        case $var in
            e) tfe;;
            i) tfi;;
            iu) tfiu;;
            ir) tfir;;
            im) tfim;;
        esac
    done
}
