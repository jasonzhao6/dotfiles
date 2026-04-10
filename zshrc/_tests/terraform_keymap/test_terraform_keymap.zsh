function test__terraform_keymap {
	assert "$(
		local show_this_help; show_this_help=$(terraform_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $TERRAFORM_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__terraform_keymap_c {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_c"
		mkdir -p $HOME/.terraform.d
		mkdir -p $HOME/project/.terraform
		touch $HOME/project/tfplan

		cd $HOME/project || return
		terraform_keymap_c
		[[ -e tfplan ]] && echo tfplan_present || echo tfplan_absent
		[[ -e .terraform ]] && echo terraform_present || echo terraform_absent
		[[ -e $HOME/.terraform.d ]] && echo d_present || echo d_absent

		rm -rf $HOME
		HOME=$home
	)" "$(
		cat <<-eof
			tfplan_absent
			terraform_absent
			d_absent
		eof
	)"
}

function test__terraform_keymap_cc {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_cc"
		mkdir -p $HOME/.terraform.d
		mkdir -p $HOME/.terraform.cache
		mkdir -p $HOME/project/.terraform
		touch $HOME/project/tfplan

		cd $HOME/project || return
		terraform_keymap_cc
		[[ -e tfplan ]] && echo tfplan_present || echo tfplan_absent
		[[ -e .terraform ]] && echo terraform_present || echo terraform_absent
		[[ -e $HOME/.terraform.d ]] && echo d_present || echo d_absent
		[[ -e $HOME/.terraform.cache ]] && echo cache_present || echo cache_absent

		rm -rf $HOME
		HOME=$home
	)" "$(
		cat <<-eof
			tfplan_absent
			terraform_absent
			d_absent
			cache_absent
		eof
	)"
}

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
		     1	project
		     2	project/module
		eof
	)"
}
