
# Skip: Cannot test b/c requires querying github
# function other_keymap_f__for_gh

function test__f__for_tf {
	assert "$(
		local home=$HOME
		local pwd=$PWD
		HOME="/tmp/test__f"
		mkdir -p $HOME/project/module/.terraform

		touch $HOME/project/main.tf
		touch $HOME/project/module/main.tf
		touch $HOME/project/module/.terraform/main.tf

		cd $HOME || return
		f tf

		rm -rf $HOME
		HOME=$home
		cd "$pwd" || return
	)" "$(
		cat <<-eof
		     1	~/project
		     2	~/project/module
		eof
	)"
}; run_with_filter test__f__for_tf


# Skip: Not testing b/c requires network call
# function other_keymap_other_keymap_k



# Skip: Not interesting b/c it has its own specs
# function other_keymap_pp

# Skip: Not testing b/c requires network call
# function other_keymap_bif

# Skip: Not interesting to test
# function other_keymap_jcurl
