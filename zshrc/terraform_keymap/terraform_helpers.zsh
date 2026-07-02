function terraform_helpers_diff {
	# A resource's body opens/closes with a brace at column 4 (2-space gutter +
	# 1-char symbol + space); nested attribute braces (e.g. changed map/object
	# values) are always indented deeper, so that column alone marks the
	# block's end without tracking brace depth
	#
	# Drift (changes made outside of Terraform) renders with the same header/
	# brace shape as planned actions, just under a different banner; keep
	# Terraform's own banner lines so a drifted resource isn't mistaken for
	# a duplicate, but only once both sections are actually present
	awk '
		/Objects have changed outside of Terraform/ {
			drift=1
			print
			print ""
			next
		}
		/^Terraform will perform the following actions:/ {
			if (drift) { print; print ""; drift=0 }
			next
		}
		/^  # / { capture=1 }
		capture { print }
		/^    }$/ { capture=0; print "" }
		/^No changes\./ { print }
		/^Plan: / { print }
	'
}

function terraform_helpers_init {
	local options=$1
	[[ -z $1 ]] && return

	# Rule: AND/OR e (OR i iu ir im)
	for var in $options; do
		case $var in
			e) terraform_keymap_e;;
			i) terraform_keymap_i;;
			iu) terraform_keymap_iu;;
			ir) terraform_keymap_ir;;
			im) terraform_keymap_im;;
		esac
	done
}
