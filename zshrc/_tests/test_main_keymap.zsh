function test__main_keymap {
	assert "$(
		local show_this_help; show_this_help=$(main_keymap | grep help | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $MAIN_ALIAS +# Show this help$" ]] && echo 1
	)" '1'
}; run_with_filter test__main_keymap

function test__main_keymap_k {
	assert "$([[ $(main_keymap_k | wc -l) -gt 200 ]] && echo 1)" '1'
}; run_with_filter test__main_keymap_k

function test__main_keymap_k__when_specifying_a_key {
	assert "$([[ $(main_keymap_k k | wc -l) -gt 3 ]] && echo 1)" '1'
}; run_with_filter test__main_keymap_k__when_specifying_a_key

function test__main_keymap_k__when_specifying_a_namespace_and_key {
	assert "$(
		main_keymap_k m k | bw
	)" "$(
		cat <<-eof
		  $ m.ki                                     # Show Kinesis keymap
		  $ m.k                                      # List keymap entries
		  $ m.k <key>                                # Filter across namespaces
		  $ m.k <namespace> <key>                    # Filter a specific namespace
		eof
	)"
}; run_with_filter test__main_keymap_k__when_specifying_a_namespace_and_key
