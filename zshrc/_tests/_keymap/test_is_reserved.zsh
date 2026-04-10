function test__is_reserved__when_keyword_is_reserved {
	assert "$(is_reserved 'do' && echo 1 || echo 2)" '1'
}

function test__is_reserved__when_command_is_reserved {
	assert "$(is_reserved 'cp' && echo 1 || echo 2)" '1'
}

function test__is_reserved__when_command_is_not_reserved {
	assert "$(is_reserved 'not_reserved_command' && echo 1 || echo 2)" '2'
}

function test__is_reserved__when_command_is_explicitly_unreserved {
	assert "$(is_reserved 'aa' && echo 1 || echo 2)" '2'
}
