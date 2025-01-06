#function test__n {
#	local show_help='# Show this help'
#	assert "$(n | grep --only-matching "$show_help")" "$(grep_color "$show_help")"
#}; run_with_filter test__n
#
#function test__n__with_a_not_found_key {
#	local show_help='# Show this help'
#	assert "$(n not_found | grep --only-matching "$show_help")" "$(grep_color "$show_help")"
#}; run_with_filter test__n__with_a_not_found_key
