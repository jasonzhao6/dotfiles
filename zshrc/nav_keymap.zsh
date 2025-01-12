NAV_NAMESPACE='nav_keymap'
NAV_ALIAS='n'

NAV_KEYMAP=(
	"$NAV_ALIAS·n <matches>* -<mismatches>* # List files & directories"
	"$NAV_ALIAS·a <matches>* -<mismatches>* # List hidden files & directories"
)

keymap_init $NAV_NAMESPACE $NAV_ALIAS "${NAV_KEYMAP[@]}"

function nav_keymap {
	keymap_invoke $NAV_NAMESPACE $NAV_ALIAS ${#NAV_KEYMAP} "${NAV_KEYMAP[@]}" "$@"
}

#
# Key mappings (Alphabetized)
#

function nav_keymap_a {
	ls -ld .* | awk '{print $9}' | args_keymap_s "$@"
}

function nav_keymap_n {
	ls -l | awk '{print $9}' | args_keymap_s "$@"
}
