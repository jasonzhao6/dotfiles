function test__t {
	local keymap='test__namespace test__keymap [test__arg1] [test__arg2]'
	local keymap_escape='test__namespace test__keymap \[test__arg1\] \[test__arg2\]'

	assert "$(t | grep --only-matching "$keymap_escape")" "$(grep_color "$keymap")"
}; run_with_filter test__t

function test__t__with_type {
	assert "$(
		t list_test 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__t__with_type

function test__t__with_type_prefix {
	assert "$(
		t list_tes 11 22
	)" "$(
		cat <<-eof
			arg1: 11
			arg2: 22
		eof
	)"
}; run_with_filter test__t__with_type_prefix

function test__opal {
	assert "$(
		opal
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-1  url-1
		     2	non-secret-placeholder-2  url-2
		eof
	)"
}; run_with_filter test__opal

function test__zsh_aliases {
	assert "$(
		local count; count=$(zsh_aliases | wc -l)
		local min_count; min_count=$(grep --count '^\talias ' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -ge $min_count ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_aliases

function test__zsh_aliases__when_counting_greps {
	assert "$(
		local count; count=$(zsh_aliases grep | wc -l)
		local actual_count; actual_count=$(grep --count '^\talias.*grep' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_aliases__when_counting_greps

function test__zsh_functions {
	assert "$(
		[[ $(zsh_functions | wc -l) -gt 10 ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_functions

function test__zsh_functions__when_counting_._functions {
	assert "$(
		local count; count=$(zsh_functions 'test__\.' | wc -l)
		local actual_count; actual_count=$(egrep --count '^function \.+ {' "$ZSHRC_DIR"/cd.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_functions__when_counting_._functions
