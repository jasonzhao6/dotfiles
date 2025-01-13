function test__terraform_keymap_e {
	assert "$(
		local home=$HOME
		local pwd=$PWD
		HOME="/tmp/test__f"
		mkdir -p $HOME/project/module/.terraform

		touch $HOME/project/main.tf
		touch $HOME/project/module/main.tf
		touch $HOME/project/module/.terraform/main.tf

		cd $HOME || return
		terraform_keymap_e

		rm -rf $HOME
		HOME=$home
		cd "$pwd" || return
	)" "$(
		cat <<-eof
		     1	~/project
		     2	~/project/module
		eof
	)"
}; run_with_filter test__terraform_keymap_e
