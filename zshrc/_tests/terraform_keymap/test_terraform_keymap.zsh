# shellcheck disable=SC2030,SC2031 # Tests override HOME inside each $(...) for isolation; subshell-local is intended
function test__terraform_keymap {
	assert "$(
		local show_this_help; show_this_help=$(terraform_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $show_this_help =~ "^  \\$ $TERRAFORM_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__terraform_keymap_a__with_tfplan {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_a__with_tfplan"
		mkdir -p $HOME/project
		touch $HOME/project/tfplan

		function terraform { echo "terraform $*"; }

		cd $HOME/project || return

		# Match the seconds loosely, so a slow test run cannot flake
		local output; output=$(terraform_keymap_a | bw)
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $output =~ "tfplan is 0m [0-9]+s old" ]] && echo age_shown
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $output =~ 'terraform apply tfplan' ]] && echo applied

		rm -rf $HOME
		HOME=$home
	)" "$(
		cat <<-eof
			age_shown
			applied
		eof
	)"
}

function test__terraform_keymap_a__with_stale_tfplan {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_a__with_stale_tfplan"
		mkdir -p $HOME/project
		touch $HOME/project/tfplan
		touch -A -001000 $HOME/project/tfplan # Backdate by 10 minutes

		function terraform { echo "terraform $*"; }

		cd $HOME/project || return

		local output; output=$(terraform_keymap_a | bw)
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $output =~ "tfplan is 10m [0-9]+s old" ]] && echo age_shown
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $output =~ "tfplan is stale \(max 5m\)" ]] && echo stale
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ ! $output =~ 'terraform apply' ]] && echo not_applied

		rm -rf $HOME
		HOME=$home
	)" "$(
		cat <<-eof
			age_shown
			stale
			not_applied
		eof
	)"
}

function test__terraform_keymap_a__with_max_age {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_a__with_max_age"
		mkdir -p $HOME/project
		touch $HOME/project/tfplan
		touch -A -001000 $HOME/project/tfplan # Backdate by 10 minutes

		function terraform { echo "terraform $*"; }

		cd $HOME/project || return

		local output; output=$(terraform_keymap_a 20 | bw)
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $output =~ "tfplan is 10m [0-9]+s old" ]] && echo age_shown
		# shellcheck disable=SC2076 # Bash false positive; quoted regex works in zsh
		[[ $output =~ 'terraform apply tfplan' ]] && echo applied

		rm -rf $HOME
		HOME=$home
	)" "$(
		cat <<-eof
			age_shown
			applied
		eof
	)"
}

function test__terraform_keymap_a__without_tfplan {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_a__without_tfplan"
		mkdir -p $HOME/project

		function terraform { echo "terraform $*"; }

		cd $HOME/project || return
		terraform_keymap_a

		rm -rf $HOME
		HOME=$home
	)" "$(red_bar 'No tfplan to apply')"
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

function test__terraform_keymap_m__with_diff {
	assert "$(
		function mate { cat; }

		cat <<-eof | pbcopy
			Terraform will perform the following actions:

			  # aws_instance.foo will be created
			  + resource "aws_instance" "foo" {
			      + ami = "ami-123"
			    }

			  # aws_instance.bar will be destroyed
			  - resource "aws_instance" "bar" {
			      - ami = "ami-456" -> null
			    }

			Plan: 1 to add, 0 to change, 1 to destroy.
		eof

		terraform_keymap_m
	)" "$(
		cat <<-eof
			  # aws_instance.foo will be created
			  + resource "aws_instance" "foo" {
			      + ami = "ami-123"
			    }

			  # aws_instance.bar will be destroyed
			  - resource "aws_instance" "bar" {
			      - ami = "ami-456" -> null
			    }

			Plan: 1 to add, 0 to change, 1 to destroy.
		eof
	)"
}

function test__terraform_keymap_m__with_nested_attribute_diff {
	assert "$(
		function mate { cat; }

		cat <<-eof | pbcopy
			Terraform will perform the following actions:

			  # aws_instance.foo will be updated in-place
			  ~ resource "aws_instance" "foo" {
			      ~ tags = {
			          - "Old" = "value" -> null
			          + "New" = "value"
			        }
			        # (3 unchanged attributes hidden)
			    }

			Plan: 0 to add, 1 to change, 0 to destroy.
		eof

		terraform_keymap_m
	)" "$(
		cat <<-eof
			  # aws_instance.foo will be updated in-place
			  ~ resource "aws_instance" "foo" {
			      ~ tags = {
			          - "Old" = "value" -> null
			          + "New" = "value"
			        }
			        # (3 unchanged attributes hidden)
			    }

			Plan: 0 to add, 1 to change, 0 to destroy.
		eof
	)"
}

function test__terraform_keymap_m__with_forget {
	assert "$(
		function mate { cat; }

		# Forget actions render with a 1-space gutter, unlike other actions
		cat <<-eof | pbcopy
			Terraform will perform the following actions:

			 # aws_instance.foo will no longer be managed by Terraform, but will not be destroyed
			 # (destroy = false is set in the configuration)
			 . resource "aws_instance" "foo" {
			        id = "i-0123456789"
			    }

			Plan: 0 to add, 0 to change, 0 to destroy.
		eof

		terraform_keymap_m
	)" "$(
		cat <<-eof
			 # aws_instance.foo will no longer be managed by Terraform, but will not be destroyed
			 # (destroy = false is set in the configuration)
			 . resource "aws_instance" "foo" {
			        id = "i-0123456789"
			    }

			Plan: 0 to add, 0 to change, 0 to destroy.
		eof
	)"
}

function test__terraform_keymap_m__with_drift {
	assert "$(
		function mate { cat; }

		cat <<-eof | pbcopy
			Note: Objects have changed outside of Terraform

			Terraform detected the following changes made outside of Terraform since the
			last "terraform apply":

			  # aws_instance.foo has changed
			  ~ resource "aws_instance" "foo" {
			        id            = "i-0123456789"
			      ~ instance_type = "t2.micro" -> "t2.nano"
			    }


			Unless you have made equivalent changes to your configuration, or ignored the
			relevant attributes using ignore_changes, the following plan may include
			actions to undo or respond to these changes.

			Terraform used the selected providers to generate the following execution
			plan. Resource actions are indicated with the following symbols:
			  ~ update in-place

			Terraform will perform the following actions:

			  # aws_instance.foo will be updated in-place
			  ~ resource "aws_instance" "foo" {
			      ~ instance_type = "t2.nano" -> "t2.micro"
			    }

			Plan: 0 to add, 1 to change, 0 to destroy.
		eof

		terraform_keymap_m
	)" "$(
		cat <<-eof
			Note: Objects have changed outside of Terraform

			  # aws_instance.foo has changed
			  ~ resource "aws_instance" "foo" {
			        id            = "i-0123456789"
			      ~ instance_type = "t2.micro" -> "t2.nano"
			    }

			Terraform will perform the following actions:

			  # aws_instance.foo will be updated in-place
			  ~ resource "aws_instance" "foo" {
			      ~ instance_type = "t2.nano" -> "t2.micro"
			    }

			Plan: 0 to add, 1 to change, 0 to destroy.
		eof
	)"
}

function test__terraform_keymap_m__with_no_changes {
	assert "$(
		function mate { cat; }

		echo 'No changes. Your infrastructure matches the configuration.' | pbcopy

		terraform_keymap_m
	)" 'No changes. Your infrastructure matches the configuration.'
}

function test__terraform_keymap_m__with_textmate_args {
	assert "$(
		# Print one arg per line, so the quoted display name stays one arg
		function mate { print -l mate "$@"; cat > /dev/null; }

		echo 'No changes. Your infrastructure matches the configuration.' | pbcopy

		terraform_keymap_m
	)" "$(
		cat <<-eof
			mate
			-m
			pasted plan
			-t
			source.terraform
		eof
	)"
}

function test__terraform_keymap_m__with_empty_pasteboard {
	assert "$(
		echo '' | pbcopy
		terraform_keymap_m
	)" "$(red_bar 'No plan in pasteboard')"
}

function test__terraform_keymap_m__with_no_diff_found {
	assert "$(
		echo 'hello world' | pbcopy
		terraform_keymap_m
	)" "$(red_bar 'No diff found in pasteboard')"
}

function test__terraform_keymap_p__drops_stale_tfplan {
	assert "$(
		local home=$HOME
		HOME="/tmp/test__terraform_keymap_p__drops_stale_tfplan"
		mkdir -p $HOME/project
		touch $HOME/project/tfplan

		function terraform { echo "terraform $*"; }

		cd $HOME/project || return
		terraform_keymap_p
		[[ -e tfplan ]] && echo tfplan_present || echo tfplan_absent

		rm -rf $HOME
		HOME=$home
	)" "$(
		cat <<-eof
			terraform plan -out=tfplan
			tfplan_absent
		eof
	)"
}

function test__terraform_keymap_t {
	assert "$(
		local home=$HOME
		local pwd=$PWD
		HOME="/tmp/test__f"
		mkdir -p $HOME/project/module/.terraform

		touch $HOME/project/main.tf
		touch $HOME/project/module/main.tf
		touch $HOME/project/module/.terraform/main.tf

		cd $HOME || return
		terraform_keymap_t

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
