function terraform_keymap_init {
	local option=$1
	[[ -z $1 ]] && return

	for var in $option; do
		case $var in
			e) terraform_keymap_e;;
			i) terraform_keymap_i;;
			iu) terraform_keymap_iu;;
			ir) terraform_keymap_ir;;
			im) terraform_keymap_im;;
		esac
	done
}
