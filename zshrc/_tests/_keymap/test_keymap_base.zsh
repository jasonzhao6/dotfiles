TEST_NAMESPACE='test_keymap'
TEST_ALIAS='test__'
TEST_DOT="${TEST_ALIAS}${KEYMAP_DOT}"

TEST_KEYMAP=(
	"${TEST_DOT}a # First"
	"${TEST_DOT}aa # First related"
	''
	"${TEST_DOT}b # Second"
	"${TEST_DOT}c # Third without args"
	"${TEST_DOT}c {arg 1} {arg 2} # Third with args"
	"${TEST_DOT}d"
	''
	"{1-9} # #1-9"
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

function test__keymap_show {
	assert "$(test_keymap | bw | strip_right)" "$(
		cat <<-eof

			Keymap

			  $ test_keymap

			  \`   1   2   3   4   5   |   6   7   8   9   0   [   ]
			      '   ,   .   p   y   |   f   g  (c)  r   l   /   =  <\>
			     (a)  o   e   u   i   |  <d>  h   t   n   s   -
			      ;   q   j   k   x   |  <b>  m   w   v   z

			  \`<>\` key initials have one mapping
			  \`()\` key initials have multiple mappings

			Usage

			  $ test__                         # Show this help
			  $ test__ {description}           # Filter by description

			  $ test__.{key}                   # Invoke {key} mapping
			  $ test__.{key} {arg}             # Invoke {key} mapping with {arg}

			  $ test__.-                       # List mappings in this namespace
			  $ test__.- {match}* {-mismatch}* # Filter mappings in this namespace

			          ^                        # The \`.\` is only for documentation
			                                   # Omit it when invoking a mapping

			Mappings

			  $ test__.a                       # First
			  $ test__.aa                      # First related

			  $ test__.b                       # Second
			  $ test__.c                       # Third without args
			  $ test__.c {arg 1} {arg 2}       # Third with args
			  $ test__.d

			  $ {1-9}                          # #1-9
			  $ cmd-\`                          # Backtick
			  $ cmd-\                          # Escape escape
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
		  $ test__.c {arg 1} {arg 2} # Third with args
		eof
	)"
}; run_with_filter test__keymap_show__with_multiple_words

function test__keymap_show__on_a_non_zsh_keymap_with_filters {
	assert "$(mg- -sel conver | bw)" "$(
		cat <<-eof

	     1	{enter} # Open conversation
	     2	j       # Older conversation
	     3	k       # Newer conversation
		eof
	)"
}; run_with_filter test__keymap_show__on_a_non_zsh_keymap_with_filters

function test__keymap_show__when_invoking_non_existent_z {
	assert "$(test_keymap z)" "$(
		cat <<-eof

			$(red_bar "\`z\` does not match any keymap description")
		eof
	)"
}; run_with_filter test__keymap_show__when_invoking_non_existent_z

function test__keymap_show__when_invoking_keymap_of_keymaps {
	assert "$(ma | grep "$ALL_NAMESPACE" | bw)" "  $ALL_NAMESPACE"
}; run_with_filter test__keymap_show__when_invoking_keymap_of_keymaps
