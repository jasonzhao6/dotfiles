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
	assert "$(caller)" 'run_with_filter'
}; run_with_filter test__caller

function test__callee {
	assert "$(callee)" 'test__callee'
}; run_with_filter test__callee

function test__echo_eval {
	assert "$(
		echo_eval echo 123 2>&1
	)" "$(
		cat <<-eof
			echo 123
			123
		eof
	)"
}; run_with_filter test__echo_eval

function test__ellipsize {
	assert "$(
		ellipsize "$(printf "%.0sX" {1..1000})" | bw | wc -c | awk '{print $1}'
	)" "$COLUMNS"
}; run_with_filter test__ellipsize

function test__epoch {
	assert "$(
		local created_at='1736873597'
		local a_century_later; a_century_later=$((created_at + 60 * 60 * 24 * 365 * 100))
		[[ $(epoch) -gt $created_at && $(epoch) -lt $a_century_later ]] && echo 1
	)" '1'
}; run_with_filter test__epoch

function test__epoch__when_specifying_0_decimal {
	assert "$(
		# shellcheck disable=SC2076
		[[ ! $(epoch) =~ '\.' ]] && echo 1
	)" '1'
}; run_with_filter test__epoch__when_specifying_0_decimal

function test__epoch__when_specifying_1_decimal {
	assert "${#$(epoch 1)#*.}" '1'
}; run_with_filter test__epoch__when_specifying_1_decimal

function test__epoch__when_specifying_3_decimal {
	assert "${#$(epoch 3)#*.}" '3'
}; run_with_filter test__epoch__when_specifying_3_decimal

function test__index_of__first {
	assert "$(index_of '10 20 30 40' 10)" '1'
}; run_with_filter test__index_of__first

function test__index_of__third {
	assert "$(index_of '10 20 30 40' 30)" '7'
}; run_with_filter test__index_of__third

function test__index_of__last {
	assert "$(index_of '10 20 30 40' 40)" '10'
}; run_with_filter test__index_of__last

function test__index_of__out_of_bound {
	assert "$(index_of '10 20 30 40' 100)" '0'
}; run_with_filter test__index_of__out_of_bound

function test__index_of__with_color {
	assert "$(index_of "$(green_bg a b c)" m)" '0'
}; run_with_filter test__index_of__with_color

function test__next_ascii__of_lower_case {
	assert "$(next_ascii a)" 'b'
}; run_with_filter test__next_ascii__of_lower_case

function test__next_ascii__of_upper_case {
	assert "$(next_ascii A)" 'B'
}; run_with_filter test__next_ascii__of_upper_case

function test__next_ascii__of_number {
	assert "$(next_ascii 0)" '1'
}; run_with_filter test__next_ascii__of_number

function test__paste_when_empty {
	assert "$(echo '123 321' | pbcopy; paste_when_empty)" '123 321'
}; run_with_filter test__paste_when_empty

function test__paste_when_empty__with_one_arg {
	assert "$(paste_when_empty 111)" '111'
}; run_with_filter test__paste_when_empty__with_one_arg

function test__paste_when_empty__with_two_args {
	assert "$(paste_when_empty '111 222')" '111 222'
}; run_with_filter test__paste_when_empty__with_two_args

function test__size_of {
	assert "$(size_of "$test__ls_dash_l")" '64'
}; run_with_filter test__size_of

function test__bw {
	assert "$(echo "\e[30m\e[47m...\e[0m" | bw)" '...'
}; run_with_filter test__bw

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
}; run_with_filter test__compact

function test__downcase {
	assert "$(echo 'HELLO world FoO BaR' | downcase)" 'hello world foo bar'
}; run_with_filter test__downcase

function test__extract_urls {
	local url='http://example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls

function test__extract_urls__with_subdomain {
	local url='http://my.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_subdomain

function test__extract_urls__with_www {
	local url='http://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_www

function test__extract_urls__with_http {
	local url='http://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_http

function test__extract_urls__with_https {
	local url='https://www.example.com'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_https

function test__extract_urls__with_path {
	local url='https://www.example.com/path'
	assert "$(echo $url | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_path

function test__extract_urls__with_query {
	local url='https://www.example.com/path?key=value'
	assert "$(echo "$url" | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_query

function test__extract_urls__with_fragment {
	local url='https://www.example.com/path?key=value#heading'
	assert "$(echo "$url" | extract_urls)" "$(pgrep_color "$url")"
}; run_with_filter test__extract_urls__with_fragment

function test__extract_urls__with_multiple_urls {
	assert "$(
		echo '2 urls https://www.example.com/path?key=value#heading, https://www.google.com' | extract_urls
	)" "$(
		cat <<-eof
			$(pgrep_color 'https://www.example.com/path?key=value#heading')
			$(pgrep_color 'https://www.google.com')
		eof
	)"
}; run_with_filter test__extract_urls__with_multiple_urls

function test__hex {
	assert "$(
		echo 123 | hex
	)" "$(
		cat <<-eof
			00000000  31 32 33 0a                                       |123.|
			00000004
		eof
	)"
}; run_with_filter test__hex

function test__ruby_strip {
	assert "$(echo '    111 222   ' | ruby_strip)" '111 222'
}; run_with_filter test__ruby_strip

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
}; run_with_filter test__ruby_strip__with_multiple_lines

function test__strip {
	assert "$(echo '    111 222   ' | strip)" '111 222'
}; run_with_filter test__strip

function test__strip_left {
	assert "$(echo '    111 222   ' | strip_left)" '111 222   '
}; run_with_filter test__strip_left

function test__strip_right {
	assert "$(echo '    111 222   ' | strip_right)" '    111 222'
}; run_with_filter test__strip_right

function test__trim {
	assert "$(echo 1234567890 | trim)" '1234567890'
}; run_with_filter test__trim

function test__trim__with_one_arg {
	assert "$(echo 1234567890 | trim 3)" '4567890'
}; run_with_filter test__trim__with_one_arg

function test__trim__with_two_args {
	assert "$(echo 1234567890 | trim 3 2)" '45678'
}; run_with_filter test__trim__with_two_args

function test__upcase {
	assert "$(echo 'HELLO world FoO BaR' | upcase)" 'HELLO WORLD FOO BAR'
}; run_with_filter test__upcase

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
}; run_with_filter test__insert_hash

function test__size {
	assert "$(echo "$test__ls_dash_l" | size)" '64'
}; run_with_filter test__size

function test__size__third_column {
	assert "$(echo "$test__ls_dash_l" | size 2)" '1'
}; run_with_filter test__size__third_column

function test__size__variable_width_column {
	# shellcheck disable=SC2086
	assert "$(echo $test__ls_dash_l | size 5)" '5'
}; run_with_filter test__size__variable_width_column

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
}; run_with_filter test__trim_column

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
}; run_with_filter test__trim_column__when_specifying_the_3rd_column

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
}; run_with_filter test__keys

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
}; run_with_filter test__trim_list
