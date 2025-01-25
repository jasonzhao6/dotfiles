function test__terraform_keymap {
	assert "$(
		local show_this_help; show_this_help=$(terraform_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $TERRAFORM_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__terraform_keymap

function test__terraform_keymap_w {
	assert "$(
		local home=$HOME
		local pwd=$PWD
		HOME="/tmp/test__f"
		mkdir -p $HOME/project/module/.terraform

		touch $HOME/project/main.tf
		touch $HOME/project/module/main.tf
		touch $HOME/project/module/.terraform/main.tf

		cd $HOME || return
		terraform_keymap_w

		rm -rf $HOME
		HOME=$home
		cd "$pwd" || return
	)" "$(
		cat <<-eof
		     1	~/project
		     2	~/project/module
		eof
	)"
}; run_with_filter test__terraform_keymap_w
