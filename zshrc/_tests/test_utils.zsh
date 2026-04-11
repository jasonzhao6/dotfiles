test__ls_dash_l=$(
	cat <<-eof
		drwxr-xr-x  9 yzhao  staff    288 Dec 29 21:58 al-archive
		-rw-r--r--  1 yzhao  staff    228 Dec 30 00:12 colordiffrc.txt
		-rw-r--r--@ 1 yzhao  staff    135 Dec 30 00:12 gitignore.txt
		-rw-r--r--@ 1 yzhao  staff     44 Dec 30 00:12 terraformrc.txt
		-rw-r--r--@ 1 yzhao  staff    871 Dec 30 00:12 tm_properties.txt
		drwxr-xr-x  6 yzhao  staff    192 Dec 29 21:58 vimium
		drwxr-xr-x  7 yzhao  staff    224 Dec 30 00:14 _tests
		-rwxr-xr-x@ 1 yzhao  staff   2208 Dec 30 00:12 _tests.zsh
		-rw-r--r--@ 1 yzhao  staff  23929 Dec 30 00:12 zshrc.txt
	eof
)

function test__caller {
	assert "$(caller)" '(eval)'
}

function test__callee {
	assert "$(callee)" 'test__callee'
}

function test__comma_num {
	assert "$(comma_num 1234567)" '1,234,567'
}

function test__comma_num__small {
	assert "$(comma_num 42)" '42'
}

function test__comma_num__negative {
	assert "$(comma_num -1234)" '-1,234'
}

function test__comma_num__zero {
	assert "$(comma_num 0)" '0'
}

function test__echo_eval {
	assert "$(
		echo_eval echo 123 2>&1
	)" "$(
		cat <<-eof
			echo 123
			123
		eof
	)"
}

function test__ellipsize {
	assert "$(
		COLUMNS=80
		ellipsize "$(printf "%.0sX" {1..1000})" | bw | wc -c | awk '{print $1}'
	)" '80'
}

function test__epoch {
	assert "$(
		local created_at='1736873597'
		local a_century_later; a_century_later=$((created_at + 60 * 60 * 24 * 365 * 100))
		[[ $(epoch) -gt $created_at && $(epoch) -lt $a_century_later ]] && echo 1
	)" '1'
}

function test__epoch__when_specifying_0_decimal {
	assert "$(
		# shellcheck disable=SC2076
		[[ ! $(epoch) =~ '\.' ]] && echo 1
	)" '1'
}

function test__epoch__when_specifying_1_decimal {
	assert "${#$(epoch 1)#*.}" '1'
}

function test__epoch__when_specifying_3_decimal {
	assert "${#$(epoch 3)#*.}" '3'
}

function test__index_of__first {
	assert "$(index_of '10 20 30 40' 10)" '1'
}

function test__index_of__third {
	assert "$(index_of '10 20 30 40' 30)" '7'
}

function test__index_of__last {
	assert "$(index_of '10 20 30 40' 40)" '10'
}

function test__index_of__out_of_bound {
	assert "$(index_of '10 20 30 40' 100)" '0'
}

function test__index_of__with_color {
	assert "$(index_of "$(green_bg a b c)" m)" '0'
}

function test__next_ascii__of_lower_case {
	assert "$(next_ascii a)" 'b'
}

function test__next_ascii__of_upper_case {
	assert "$(next_ascii A)" 'B'
}

function test__next_ascii__of_number {
	assert "$(next_ascii 0)" '1'
}

function test__paste_when_empty {
	assert "$(echo '123 321' | pbcopy; paste_when_empty)" '123 321'
}

function test__paste_when_empty__with_one_arg {
	assert "$(paste_when_empty 111)" '111'
}

function test__paste_when_empty__with_two_args {
	assert "$(paste_when_empty '111 222')" '111 222'
}

function test__size_of {
	assert "$(size_of "$test__ls_dash_l")" '64'
}

function test__bw {
	assert "$(echo "\e[30m\e[47m...\e[0m" | bw)" '...'
}

function test__compact {
	local input; input=$(
		cat <<-eof
			[


			]
		eof
	)

	assert "$(
		echo "$input" | compact
	)" "$(
		cat <<-eof
			[
			]
		eof
	)"
}

function test__downcase {
	assert "$(echo 'HELLO world FoO BaR' | downcase)" 'hello world foo bar'
}

function test__encode_url {
	assert "$(echo -n 'hello world&foo=bar' | encode_url)" 'hello%20world%26foo%3Dbar'
}

function test__extract_urls {
	local url='http://example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_subdomain {
	local url='http://my.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_www {
	local url='http://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_http {
	local url='http://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_https {
	local url='https://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_path {
	local url='https://www.example.com/path'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_query {
	local url='https://www.example.com/path?key=value'
	assert "$(echo "$url" | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_fragment {
	local url='https://www.example.com/path?key=value#heading'
	assert "$(echo "$url" | extract_urls)" "$(pgrep_color "$url")"
}

function test__extract_urls__with_multiple_urls {
	assert "$(
		echo '2 urls https://www.example.com/path?key=value#heading, https://www.google.com' | extract_urls
	)" "$(
		cat <<-eof
			$(pgrep_color 'https://www.example.com/path?key=value#heading')
			$(pgrep_color 'https://www.google.com')
		eof
	)"
}

function test__hex {
	assert "$(
		echo 123 | hex
	)" "$(
		cat <<-eof
			00000000  31 32 33 0a                                       |123.|
			00000004
		eof
	)"
}

function test__ruby_strip {
	assert "$(echo '    111 222   ' | ruby_strip)" '111 222'
}

function test__ruby_strip__with_multiple_lines {
	local input; input=$(
		cat <<-eof


			foo 23
			foo 34

		eof
	)

	assert "$(echo "$input" | ruby_strip)" "$(
		cat <<-eof
			foo 23
			foo 34
		eof
	)"
}

function test__strip {
	assert "$(echo '    111 222   ' | strip)" '111 222'
}

function test__strip_left {
	assert "$(echo '    111 222   ' | strip_left)" '111 222   '
}

function test__strip_right {
	assert "$(echo '    111 222   ' | strip_right)" '    111 222'
}

function test__trim {
	assert "$(echo 1234567890 | trim)" '1234567890'
}

function test__trim__with_one_arg {
	assert "$(echo 1234567890 | trim 3)" '4567890'
}

function test__trim__with_two_args {
	assert "$(echo 1234567890 | trim 3 2)" '45678'
}

function test__upcase {
	assert "$(echo 'HELLO world FoO BaR' | upcase)" 'HELLO WORLD FOO BAR'
}

function test__insert_hash {
	assert "$(
		# shellcheck disable=SC2086
		echo $test__ls_dash_l | insert_hash
	)" "$(
		cat <<-eof
			drwxr-xr-x  # 9 yzhao  staff    288 Dec 29 21:58 al-archive
			-rw-r--r--  # 1 yzhao  staff    228 Dec 30 00:12 colordiffrc.txt
			-rw-r--r--@ # 1 yzhao  staff    135 Dec 30 00:12 gitignore.txt
			-rw-r--r--@ # 1 yzhao  staff     44 Dec 30 00:12 terraformrc.txt
			-rw-r--r--@ # 1 yzhao  staff    871 Dec 30 00:12 tm_properties.txt
			drwxr-xr-x  # 6 yzhao  staff    192 Dec 29 21:58 vimium
			drwxr-xr-x  # 7 yzhao  staff    224 Dec 30 00:14 _tests
			-rwxr-xr-x@ # 1 yzhao  staff   2208 Dec 30 00:12 _tests.zsh
			-rw-r--r--@ # 1 yzhao  staff  23929 Dec 30 00:12 zshrc.txt
		eof
)"
}

function test__size {
	assert "$(echo "$test__ls_dash_l" | size)" '64'
}

function test__size__third_column {
	assert "$(echo "$test__ls_dash_l" | size 2)" '1'
}

function test__size__variable_width_column {
	# shellcheck disable=SC2086
	assert "$(echo $test__ls_dash_l | size 5)" '5'
}

function test__trim_column {
	assert "$(
		echo "$test__ls_dash_l" | trim_column
	)" "$(
		cat <<-eof
			9 yzhao staff 288 Dec 29 21:58 al-archive
			1 yzhao staff 228 Dec 30 00:12 colordiffrc.txt
			1 yzhao staff 135 Dec 30 00:12 gitignore.txt
			1 yzhao staff 44 Dec 30 00:12 terraformrc.txt
			1 yzhao staff 871 Dec 30 00:12 tm_properties.txt
			6 yzhao staff 192 Dec 29 21:58 vimium
			7 yzhao staff 224 Dec 30 00:14 _tests
			1 yzhao staff 2208 Dec 30 00:12 _tests.zsh
			1 yzhao staff 23929 Dec 30 00:12 zshrc.txt
		eof
	)"
}

function test__trim_column__when_specifying_the_3rd_column {
	assert "$(
		echo "$test__ls_dash_l" | trim_column 3
	)" "$(
		cat <<-eof
			drwxr-xr-x 9 staff 288 Dec 29 21:58 al-archive
			-rw-r--r-- 1 staff 228 Dec 30 00:12 colordiffrc.txt
			-rw-r--r--@ 1 staff 135 Dec 30 00:12 gitignore.txt
			-rw-r--r--@ 1 staff 44 Dec 30 00:12 terraformrc.txt
			-rw-r--r--@ 1 staff 871 Dec 30 00:12 tm_properties.txt
			drwxr-xr-x 6 staff 192 Dec 29 21:58 vimium
			drwxr-xr-x 7 staff 224 Dec 30 00:14 _tests
			-rwxr-xr-x@ 1 staff 2208 Dec 30 00:12 _tests.zsh
			-rw-r--r--@ 1 staff 23929 Dec 30 00:12 zshrc.txt
		eof
	)"
}

function test__keys {
	local input; input=$(
		cat <<-eof
			{
			  "key1": "value1",
			  "key2": "value2",
			  "key3": "value3"
			}
		eof
	)

	assert "$(
		echo "$input" | keys
	)" "$(
		cat <<-eof
		     1	key1
		     2	key2
		     3	key3
		eof
	)"
}

function test__trim_list {
	local input; input=$(
		cat <<-eof
			[
			  "row-1",
			  "row-2",
			  "row-3"
			]
		eof
	)

	assert "$(
		echo "$input" | trim_list
	)" "$(
		cat <<-eof
			row-1
			row-2
			row-3
		eof
	)"
}
