function test__args_save {
	assert "$(echo "$input" | args_save)" "$(
		cat <<-eof
		     1	terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		     5	terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__args_save

function test__args_save__with_leading_whitespace {
	assert "$(echo "$input_with_whitespace" | args_save)" "$(
		cat <<-eof
		     1	  terraform-application-region-shared-1
		     2	terraform-application-region-shared-2
		     3	  terraform-application-region-shared-3
		     4	terraform-application-region-program-A
		eof
	)"
}; run_with_filter test__args_save__with_leading_whitespace

function test__args_save__with_hash_inserted {
	assert "$(echo "$input_with_headers" | args_save 'insert `#`')" "$(
		cat <<-eof
		     1	MANIFEST                                # COMMENT
		     2	terraform-application-region-shared-1   # hello world
		     3	terraform-application-region-shared-2   # foo bar
		     4	terraform-application-region-shared-3   # sup
		     5	terraform-application-region-program-A  # how are you
		     6	terraform-application-region-program-B  # select via headers for this one
		eof
	)"
}; run_with_filter test__args_save__with_hash_inserted
