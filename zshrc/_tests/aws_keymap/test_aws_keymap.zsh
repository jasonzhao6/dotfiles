function test__aws_keymap {
	assert "$(
		local show_this_help; show_this_help=$(aws_keymap | grep 'Show this keymap' | bw)

		# shellcheck disable=SC2076
		[[ $show_this_help =~ "^  \\$ $AWS_ALIAS +# Show this keymap$" ]] && echo 1
	)" '1'
}

function test__aws_keymap_c {	assert "$(
		aws_keymap_c
		pbpaste
	)" "$(
		cat <<-eof
			$(green_bar History bindings copied to pasteboard)
			bind '"\e[A": history-search-backward'
			bind '"\e[B": history-search-forward'
		eof
	)"
}

function test__aws_keymap_o__with_numeric_input {
	assert "$(
		local orig=$AWS_ACCOUNTS_TSV
		AWS_ACCOUNTS_TSV=/tmp/test__aws_keymap_o.tsv
		printf 'acme-prod\t111111111111\nacme-staging\t222222222222\n' > "$AWS_ACCOUNTS_TSV"

		aws_keymap_o 111111111111

		rm -f "$AWS_ACCOUNTS_TSV"
		AWS_ACCOUNTS_TSV=$orig
	)" "$(printf '111111111111\tacme-prod')"
}

function test__aws_keymap_o__with_text_input {
	assert "$(
		local orig=$AWS_ACCOUNTS_TSV
		AWS_ACCOUNTS_TSV=/tmp/test__aws_keymap_o.tsv
		printf 'acme-prod\t111111111111\nacme-staging\t222222222222\n' > "$AWS_ACCOUNTS_TSV"

		aws_keymap_o staging

		rm -f "$AWS_ACCOUNTS_TSV"
		AWS_ACCOUNTS_TSV=$orig
	)" "$(printf '222222222222\tacme-staging')"
}

function test__aws_keymap_s {
	assert "$(
		aws_keymap_s
	)" "$(
		cat <<-eof
		     1	role_name_1  request_page_url_1
		     2	role_name_2  request_page_url_2
		eof
	)"
}

function test__aws_keymap_s__when_filtering_for_2 {
	assert "$(
		aws_keymap_s -1
	)" "$(
		cat <<-eof
		     1	role_name_2  request_page_url_2
		eof
	)"
}
