function test__1 {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		1 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-shared-1
			terraform-application-region-shared-1
		eof
	)"
}; run_with_filter test__1

function test__5 {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		5 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__5

function test__6 {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		6 echo 2>&1
	)" "echo "
}; run_with_filter test__6

function test__0 {
	assert "$(
		echo "$test__input" | args_keymap_s > /dev/null
		0 echo 2>&1
	)" "$(
		cat <<-eof
			echo terraform-application-region-program-B
			terraform-application-region-program-B
		eof
	)"
}; run_with_filter test__0
