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
	"(|)? ${TEST_DOT}e"
	''
	"<1-9> # #1-9"
	"cmd-\` # Backtick"
	"cmd-$KEYMAP_ESCAPE # Escape escape"
)

keymap_init $TEST_NAMESPACE $TEST_ALIAS "${join_dups[@]}"

# shellcheck disable=SC2120 # This function can be called without arg to print help
function test_keymap {
	keymap_show $TEST_NAMESPACE $TEST_ALIAS ${#TEST_KEYMAP} "${TEST_KEYMAP[@]}" "$@"
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
		which ${TEST_ALIAS}b
	)" "$(
		cat <<-eof
			test__: aliased to test_keymap
			test__b not found
		eof
	)"
}; run_with_filter test__keymap_init__still_sets_some_aliases_with_disjoint_duplicates

function test__keymap_show {
	assert "$(test_keymap | bw | strip_right)" "$(
		cat <<-eof

			Keymap: test_keymap.zsh

			  \`   1   2   3   4   5   |   6   7   8   9   0   [   ]
			      '   ,   .   p   y   |   f   g  (c)  r   l   /   =  <\>
			     (a)  o  <e>  u   i   |  <d>  h   t   n   s   -
			      ;   q   j   k   x   |  <b>  m   w   v   z

			  \`<>\` key initials have one mapping
			  \`()\` key initials have multiple mappings

			Keymap Usage

			  $ test__                   # Show this keymap
			  $ test__ <regex>           # Search this keymap

			  $ test__.<key>             # This mapping takes no variable
			  $ test__.<key> <var>       # This mapping takes one variable
			  $ test__.<key> <var>?      # This mapping takes zero or one variable
			  $ test__.<key> <var>*      # This mapping takes zero or multiple variables
			  $ test__.<key> (1-10)      # This mapping takes an exact value from the list
			  $ (|)? test__.<key>        # This mapping can be invoked after a \`|\`

			          ^                  # The \`.\` is only for documentation
			                             # Omit it when invoking a mapping

			Keymap List

			  $ test__.a                 # First
			  $ test__.aa                # First related

			  $ test__.b                 # Second
			  $ test__.c                 # Third without args
			  $ test__.c <arg 1> <arg 2> # Third with args
			  $ test__.d
			  $ (|)? test__.e

			  $ <1-9>                    # #1-9
			  $ cmd-\`                    # Backtick
			  $ cmd-\                    # Escape escape
		eof
	)"
}; run_with_filter test__keymap_show

function test__keymap_show__with_partial_word {
	assert "$(test_keymap fir | bw)" "$(
		cat <<-eof

		  $ test__.a  # First
		  $ test__.aa # First related
		eof
	)"
}; run_with_filter test__keymap_show__with_partial_word

function test__keymap_show__with_multiple_words {
	assert "$(test_keymap third with | bw)" "$(
		cat <<-eof

		  $ test__.c                 # Third without args
		  $ test__.c <arg 1> <arg 2> # Third with args
		eof
	)"
}; run_with_filter test__keymap_show__with_multiple_words

function test__keymap_show__with_no_match {
	assert "$(test_keymap z)" "$(
		cat <<-eof

			$(red_bar "\`z\` does not match any description")
		eof
	)"
}; run_with_filter test__keymap_show__with_no_match
