function test__o {
	local show_help='# Show this help'
	assert "$(o | grep --only-matching "$show_help")" "$(grep_color "$show_help")"
}; run_with_filter test__o

function test__o__with_a_not_found_key {
	local show_help='# Show this help'
	assert "$(o not_found | grep --only-matching "$show_help")" "$(grep_color "$show_help")"
}; run_with_filter test__o__with_a_not_found_key
