TEST_NAMESPACE='test_keymap'
TEST_ALIAS='test__'
TEST_DOT="${TEST_ALIAS}${KEYMAP_DOT}"

TEST_KEYMAP=(
	"${TEST_DOT}a # First"
	''
	"${TEST_DOT}b # Second"
	"${TEST_DOT}c # Third"
)

#function test_keymap {
#	keymap_invoke $TEST_NAMESPACE $TEST_ALIAS ${#TEST_KEYMAP} "${TEST_KEYMAP[@]}" "$@"
#}

function test__keymap_init__it_sets_alias {
	assert "$(
		keymap_init $TEST_NAMESPACE $TEST_ALIAS "${TEST_KEYMAP[@]}"
		which $TEST_ALIAS
	)" "$TEST_ALIAS: aliased to $TEST_NAMESPACE"
}; run_with_filter test__keymap_init__it_sets_alias

function test__keymap_init__it_sets_alias- {
	assert "$(
		keymap_init $TEST_NAMESPACE $TEST_ALIAS "${TEST_KEYMAP[@]}"
		which $TEST_ALIAS-
	)" "$TEST_ALIAS-: aliased to keymap_filter_entries $TEST_NAMESPACE"
}; run_with_filter test__keymap_init__it_sets_alias-

function test__keymap_init__it_sets_key_alias {
	assert "$(
		keymap_init $TEST_NAMESPACE $TEST_ALIAS "${TEST_KEYMAP[@]}"
		which ${TEST_ALIAS}b
	)" "${TEST_ALIAS}b: aliased to ${TEST_NAMESPACE}_b"
}; run_with_filter test__keymap_init__it_sets_key_alias

function test__keymap_init__with_join_duplicates {
	local join_dups=(
		"${TEST_DOT}a # First"
		"${TEST_DOT}a # First"
		''
		"${TEST_DOT}b # Second"
		"${TEST_DOT}c # Third"
	)

	assert "$(
		keymap_init $TEST_NAMESPACE $TEST_ALIAS "${join_dups[@]}"
	)" ''
}; run_with_filter test__keymap_init__with_join_duplicates

function test__keymap_init__with_disjoint_duplicates {
	local join_dups=(
		"${TEST_DOT}a # First"
		''
		"${TEST_DOT}a # First"
		"${TEST_DOT}b # Second"
		"${TEST_DOT}c # Third"
	)

	assert "$(
		keymap_init $TEST_NAMESPACE $TEST_ALIAS "${join_dups[@]}"
	)" "$(
		cat <<-eof

			$(red_bar '`test__.a` has duplicate key mappings')
		eof
	)"
}; run_with_filter test__keymap_init__with_disjoint_duplicates
