function test__zsh_keymap_a {
	assert "$(
		local count; count=$(zsh_keymap_a | wc -l)
		local min_count; min_count=$(grep --count '^\talias ' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -ge $min_count ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_keymap_a

function test__zsh_keymap_a__when_counting_greps {
	assert "$(
		local count; count=$(zsh_keymap_a grep | wc -l)
		local actual_count; actual_count=$(grep --count '^\talias.*grep' "$ZSHRC_DIR"/colors.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_keymap_a__when_counting_greps

function test__zsh_keymap_f {
	assert "$(
		[[ $(zsh_keymap_f | wc -l) -gt 10 ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_keymap_f

function test__zsh_keymap_f__when_counting_._functions {
	assert "$(
		local count; count=$(zsh_keymap_f '^\.\.' | wc -l)
		local actual_count; actual_count=$(egrep --count '^function \.+ {' "$ZSHRC_DIR"/cd.zsh)

		[[ $count -eq actual_count ]] && echo 1
	)" '1'
}; run_with_filter test__zsh_keymap_f__when_counting_._functions

function test__zsh_keymap_h {
	local history_entries; history_entries=$(
		cat <<-eof
			: 1735711246:0;echo 5
			: 1735711248:0;echo 1
			: 1735711249:0;echo 3
			: 1735711249:0;echo 3
			: 1735711250:0;echo 3
			: 1735711251:0;echo 4
			: 1735711252:0;echo 2
		eof
	)

	# shellcheck disable=SC2030
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__zsh_keymap_h'
		echo "$history_entries" > $HISTFILE

		zh

		rm $HISTFILE
		HISTFILE=$histfile
	)" "$(
		cat <<-eof
		     1	echo 1
		     2	echo 2
		     3	echo 3
		     4	echo 4
		     5	echo 5
		eof
	)"
}; run_with_filter test__zsh_keymap_h

function test__zsh_keymap_h__when_filtering {
	local history_entries; history_entries=$(
		cat <<-eof
			: 1735711246:0;echo 5
			: 1735711248:0;echo 1
			: 1735711249:0;echo 3
			: 1735711249:0;echo 3
			: 1735711250:0;echo 3
			: 1735711251:0;echo 4
			: 1735711252:0;echo 2
		eof
	)

	# shellcheck disable=SC2030
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__zsh_keymap_h__when_filtering'
		echo "$history_entries" > $HISTFILE

		zh 3

		rm $HISTFILE
		HISTFILE=$histfile
	)" "$(
		cat <<-eof
		     1	echo $(grep_color 3)
		eof
	)"
}; run_with_filter test__zsh_keymap_h__when_filtering

function test__zsh_keymap_hc {
	# shellcheck disable=SC2031
	assert "$(
		local histfile=$HISTFILE
		HISTFILE='/tmp/test__h'
		touch $HISTFILE

		zhc
		[[ -e $HISTFILE ]] && echo present || echo absent

		HISTFILE=$histfile
	)" 'absent'
}; run_with_filter test__zsh_keymap_hc

function test__zsh_keymap_w {
	assert "$(
		zsh_keymap_w zsh_keymap_w
	)" "$(
		cat <<-eof
		     1	zsh_keymap_w () {
		     2		which "\$1" | args_keymap_s
		     3	}
		eof
	)"
}; run_with_filter test__zsh_keymap_w

function test__zsh_keymap_z__when_args_history_is_not_initialized {
	args_history_init
	local args_history_max=$ARGS_HISTORY_MAX

	assert "$(
		ARGS_HISTORY_MAX=
		ZSHRC_UNDER_TESTING=1 zsh_keymap_z
		echo "$ARGS_HISTORY_MAX"
	)" "$args_history_max"

	args_history_reset
}; run_with_filter test__zsh_keymap_z__when_args_history_is_not_initialized

function test__zsh_keymap_z__when_args_history_is_already_initialized {
	local overwrite='<overwrite>'

	assert "$(
		ARGS_HISTORY_MAX=$overwrite
		ZSHRC_UNDER_TESTING=1 zsh_keymap_z
		echo $ARGS_HISTORY_MAX
	)" "$overwrite"

	args_history_reset
}; run_with_filter test__zsh_keymap_z__when_args_history_is_already_initialized
