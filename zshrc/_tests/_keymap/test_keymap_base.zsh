TEST_NAMESPACE='test_keymap'
TEST_ALIAS='test__'
TEST_DOT="${TEST_ALIAS}${KEYMAP_DOT}"

TEST_KEYMAP=(
	"${TEST_DOT}a # First"
	"${TEST_DOT}aa # First related"
	''
	"${TEST_DOT}b # Second"
	"${TEST_DOT}c # Third without args"
	"${TEST_DOT}c <arg 1> <arg 2> # Third with args"
	"${TEST_DOT}d"
)

keymap_init $TEST_NAMESPACE $TEST_ALIAS "${join_dups[@]}"

# shellcheck disable=SC2120 # This function can be called without arg to print help
function test_keymap {
	keymap_invoke $TEST_NAMESPACE $TEST_ALIAS ${#TEST_KEYMAP} "${TEST_KEYMAP[@]}" "$@"
}

function test_keymap_b {
	echo 'Second'
}

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

function test__keymap_init__with_joint_duplicates {
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
}; run_with_filter test__keymap_init__with_joint_duplicates

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

			$(red_bar "\`$TEST_NAMESPACE\` has duplicate \`$TEST_ALIAS.a\` entries")
		eof
	)"
}; run_with_filter test__keymap_init__with_disjoint_duplicates

function test__keymap_init__still_sets_some_aliases_with_disjoint_duplicates {
	local join_dups=(
		"${TEST_DOT}a # First"
		''
		"${TEST_DOT}a # First"
		"${TEST_DOT}b # Second"
		"${TEST_DOT}c # Third"
	)

	assert "$(
		keymap_init $TEST_NAMESPACE $TEST_ALIAS "${join_dups[@]}" > /dev/null
		which $TEST_ALIAS
		which $TEST_ALIAS-
		which ${TEST_ALIAS}b
	)" "$(
		cat <<-eof
			test__: aliased to test_keymap
			test__-: aliased to keymap_filter_entries test_keymap
			test__b not found
		eof
	)"
}; run_with_filter test__keymap_init__still_sets_some_aliases_with_disjoint_duplicates

function test__keymap_invoke {
	assert "$(test_keymap | bw | strip_right)" "$(
		cat <<-eof

			Name

			  test_keymap

			   \`   1   2   3   4   5   |   6   7   8   9   0   [   ]
			       '   ,   .   p   y   |   f   g  [c]  r   l   /   =
			      [a]  o   e   u   i   |  <d>  h   t   n   s   -
			       ;   q   j   k   x   |  <b>  m   w   v   z

			   \`<>\` key initials have singular mappings
			   \`[]\` key initials have multiple mappings

			Usage

			  $ test__                         # Show this help

			  $ test__.<key>                   # Invoke <key> mapping
			  $ test__.<key> <arg>             # Invoke <key> mapping with <arg>

			  $ test__.-                       # List key mappings in this namespace
			  $ test__.- <match>* <-mismatch>* # Filter key mappings in this namespace

			          ^                        # \`.\` represents an optional space character
			                                   # E.g To invoke \`a.b\`, use either \`ab\` or \`a b\`

			Keymap

			  $ test__.a                       # First
			  $ test__.aa                      # First related

			  $ test__.b                       # Second
			  $ test__.c                       # Third without args
			  $ test__.c <arg 1> <arg 2>       # Third with args
			  $ test__.d
		eof
	)"
}; run_with_filter test__keymap_invoke

function test__keymap_invoke__when_invoking_- {
	assert "$(test_keymap -)" "$(
		cat <<-eof

		     1	$ test__.a                 # First
		     2	$ test__.aa                # First related
		     3	$ test__.b                 # Second
		     4	$ test__.c                 # Third without args
		     5	$ test__.c <arg 1> <arg 2> # Third with args
		     6	$ test__.d
		eof
	)"
}; run_with_filter test__keymap_invoke__when_invoking_-

function test__keymap_invoke__when_invoking_b {
	assert "$(test_keymap b)" 'Second'
}; run_with_filter test__keymap_invoke__when_invoking_b

function test__keymap_invoke__when_invoking_non_existent_z {
	assert "$(test_keymap z)" "$(
		cat <<-eof

			$(red_bar "\`z\` key does not exist in \`$TEST_NAMESPACE\`")
		eof
	)"
}; run_with_filter test__keymap_invoke__when_invoking_non_existent_z
