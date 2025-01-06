function test__t {
	local show_help='# Show this help'
	assert "$(t | grep --only-matching "$show_help")" "$(grep_color "$show_help")"
}; run_with_filter test__t

function test__t__with_a_not_found_key {
	local show_help='# Show this help'
	assert "$(t not_found | grep --only-matching "$show_help")" "$(grep_color "$show_help")"
}; run_with_filter test__t__with_a_not_found_key

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

function test__t_o__when_filtering_for_2 {
	assert "$(
		t o 2
	)" "$(
		cat <<-eof
		     1	non-secret-placeholder-2  url-2
		eof
	)"
}; run_with_filter test__t_o__when_filtering_for_2

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
		local count; count=$(t zf '\.\.' | wc -l)
		local actual_count; actual_count=$(egrep --count '^function \.+ {' "$ZSHRC_DIR"/cd.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__t_zf__when_counting_._functions
