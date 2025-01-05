function test__t {
	local keymap='t test [arg1] [arg2]'
	local keymap_escape='t test \[arg1\] \[arg2\]'

	assert "$(t | grep --only-matching "$keymap_escape")" "$(grep_color "$keymap")"
}; run_with_filter test__t

function test__t__with_a_not_found_keymap {
	local keymap='t test [arg1] [arg2]'
	local keymap_escape='t test \[arg1\] \[arg2\]'

	assert "$(t not_found| grep --only-matching "$keymap_escape")" "$(grep_color "$keymap")"
}; run_with_filter test__t__with_a_not_found_keymap

function test__t__with_the_test_keymap {
	assert "$(
		t test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__t__with_the_test_keymap

function test__t_o {
	assert "$(
		t o
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1  url-1
		     2	non-secret-placeholder-2  url-2
		eof
	)"
}; run_with_filter test__t_o

function test__t_za {
	assert "$(
		local count; count=$(t za | wc -l)
		local min_count; min_count=$(grep --count '^\talias ' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -ge $min_count ]] && echo 1
	)" '1'
}; run_with_filter test__t_za

function test__t_za__when_counting_greps {
	assert "$(
		local count; count=$(t za grep | wc -l)
		local actual_count; actual_count=$(grep --count '^\talias.*grep' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__t_za__when_counting_greps

function test__t_zf {
	assert "$(
		[[ $(t zf | wc -l) -gt 10 ]] && echo 1
	)" '1'
}; run_with_filter test__t_zf

function test__t_zf__when_counting_._functions {
	assert "$(
		local count; count=$(t zf 'test__\.' | wc -l)
		local actual_count; actual_count=$(egrep --count '^function \.+ {' "$ZSHRC_DIR"/cd.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__t_zf__when_counting_._functions
